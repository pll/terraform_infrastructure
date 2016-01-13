#!/usr/bin/python

import ConfigParser
import logging
import os
import socket
from subprocess import ( PIPE,
                         STDOUT,
                         Popen,
                       )
import sys

import argparse

myprog  = os.path.abspath(__file__)
cwd     = os.path.dirname(myprog)
baseDir = os.path.dirname(cwd)

stateDir            = os.path.join(cwd, 'state')
remoteStateDir      = os.path.join(cwd, '.terraform')
remoteStateLinkName = 'terraform.tfstate'

TF = "/usr/local/bin/terraform"

def main():
    opts,tfOpts = parseArgs(sys.argv)
    tfOpts.remove('--')
    tfOpts.insert(0, TF)
    config = ConfigParser.ConfigParser()

    config.read(os.path.expanduser('~/.aws/credentials'))
    key          = config.get(opts.profile, 'aws_access_key_id')
    secret       = config.get(opts.profile, 'aws_secret_access_key')

    os.environ['AWS_ACCESS_KEY_ID']     = key
    os.environ['AWS_SECRET_ACCESS_KEY'] = secret

    flags = []

    flags.append("-var='aws_access_key=%s'" % key)
    flags.append("-var='aws_secret_key=%s'" % secret)

    tfVars  = "-var-file=var-files/%s" % opts.vpc
    tfState = "-state=state/%s" % opts.vpc

    flags.append(tfVars)
    if not remoteState(opts.vpc):
        flags.append(tfState)

    tfFlags = ' '.join(flags)
    print "Key    = %s" % key
    print "Secret = %s" % secret
    print "VPC    = %s" % opts.vpc


    # cmd = flags
    cmdOpts = tfOpts + flags
    if tfOpts[1] == 'show':
        cmdOpts = tfOpts
        
    if tfOpts[1] == 'remote':
        remoteCmd = [
            "AWS_ACCESS_KEY_ID=%s" % key,
            "AWS_SECRET_ACCESS_KEY=%s" % secret,
            "%s remote config -backend S3" % TF,
            "-backend-config='bucket=%s'" % opts.profile,
            "-backend-config='key=terraform-state/%s'" % opts.vpc,
            "-state='state/%s'" % opts.vpc,
            "-backup='state/%s.backup'" % opts.vpc,
            "-backend-config='region=%s'" % opts.region
        ]
        runCommand(remoteCmd)
        setStateFile(opts.vpc)
        sys.exit()
            
    setStateFile(opts.vpc)
    runCommand(cmdOpts)


def runCommand(cmd):
    cmdString = ' '.join(cmd)
    print cmdString
    tf = Popen( cmdString,
                shell   = True,
                bufsize = 0,
                stderr  = STDOUT
                )
    (out, err) = tf.communicate()
    if err:
        #print "Error: %s" % err
        sys.exit(err)
    print out

def setStateFile(vpc):

    # Filename: <vpc name>.tfstate
    dstFile = "%s.tfstate" % vpc

    # save the our current dir so we can move back to it later
    pwd     = os.getcwd()

    # Move into the .terraform dir
    os.chdir(remoteStateDir),

    # Force delete of backup state file
    try:
        os.unlink("%s.backup" % remoteStateLinkName)
    except:
        pass

    print "Renaming \n\t%s \nto:\n\t%s" % (remoteStateLinkName, dstFile)

    # Does .terraform/terraform.tfstate exist?
    if os.path.exists(remoteStateLinkName):
        # Yes, but is it a symlink?
        if os.path.islink(remoteStateLinkName):
            # Yes, but is it pointing to the correct place?
            if statePointsElsewhere(vpc):
                # No, so unlink it and re-link to my VPC state.
                os.unlink(remoteStateLinkName)
                os.symlink(dstFile, remoteStateLinkName)
        # It's not a symlink, so let's rename .terraform/terraform.tfstate
        # to .terraform/$vpc.tfstate and link it back
        else:
            os.rename(remoteStateLinkName, dstFile)
            os.symlink(dstFile, remoteStateLinkName)
    # It doesn't exist, so we should probably just return and do nothing.
    os.chdir(pwd)

def remoteState(vpc):
    return os.path.exists(os.path.join(remoteStateDir, "%s.tfstate" % vpc))
    
def statePointsElsewhere(vpc):
    link   = os.path.join(remoteStateDir,remoteStateLinkName)
    target = os.path.join(remoteStateDir, "%s.tfstate" % vpc)
    if os.path.islink(link) and (os.readlink(link) != target):
        return True
    return False
    
  
def parseArgs(argv):
    """Parse any command line args, on error or lack of args, call usage()

       Parameters:
         argv  list of args passed in on the command line.

       Returns
         list of set options
         list of additional args not set as options
         """
    descrDoc    = "Run terraform to build a VPC"
    profileDoc  = "Use PROFILE as listed in ~/.aws/credentials"
    regionDoc   = "Set region for S3 bucket to store remote config state in"
    vpcDoc      = "Name of the VPC to create"
    
    # Option help strings:
    parser     = argparse.ArgumentParser( prog        = myprog,
                                          description = descrDoc
                                        )

    requiredOpts = parser.add_argument_group('required')
    requiredOpts.add_argument('--profile',
                              action   = 'store',
                              required = True,
                              dest     = 'profile',
                              help     = profileDoc,
                             ) 
    requiredOpts.add_argument('--vpc',
                              action   = 'store',
                              required = True,
                              dest     = 'vpc',
                              help     = vpcDoc,
                             )

    remoteOpts = parser.add_argument_group('remote')
    remoteOpts.add_argument('--region',
                            action  = 'store',
                            dest    = 'region',
                            help    = regionDoc,
                           )

    opts, tfOpts = parser.parse_known_args()

    msg = ''
    if tfOpts[1] == 'remote' and not opts.region:
        msg = "You must set --region when using remote"
    if (len(argv) < 2):
        printHelp(msg,parser)

    if msg:
        printHelp(msg, parser)
        
    return opts, tfOpts

def printHelp(msg, parser):
    if msg:
        print "\nERROR: ",msg,"\n"
    parser.print_help()
    sys.exit(1)

if __name__ == '__main__':
    sys.exit(main())

