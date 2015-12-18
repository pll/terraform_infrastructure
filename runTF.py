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
    opts   = parseArgs(sys.argv)
    config = ConfigParser.ConfigParser()

    config.read(os.path.expanduser('~/.aws/credentials'))
    key          = config.get(opts.profile, 'aws_access_key_id')
    secret       = config.get(opts.profile, 'aws_secret_access_key')

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


    cmd = flags
    if opts.apply:
        cmd.insert(0,"apply")
    if opts.tfget:
        cmd.insert(0,'get')
    if opts.plan:
        cmd.insert(0,'plan -module-depth=-1')

    if opts.refresh:
        cmd.insert(0,'refresh')

    if opts.destroy:
        cmd.insert(0, 'destroy')
        if opts.force:
            cmd.insert(1, '-force')
            

    if opts.remote:
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
            
    cmd.insert(0,TF)
    setStateFile(opts.vpc)
    runCommand(cmd)


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
    applyDoc   = "Run 'terraform apply'"
    descrDoc   = "Run terraform to build a VPC"
    destroyDoc = "Run 'terraform destroy'"
    forceDoc   = "Add -force to 'terraform destroy'"
    planDoc    = "Run 'terraform plan'"
    profileDoc = "Use PROFILE as listed in ~/.aws/credentials"
    remoteDoc  = "Configure VPC for remote state"
    regionDoc  = "Set region for S3 bucket to store remote config state in"
    refreshDoc = "Run 'terraform refresh'"
    tfgetDoc   = "Call terraform get to fetch all modules for this config"
    vpcDoc     = "Name of the VPC to create"
    
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

    applyOpts = parser.add_argument_group('apply')
    applyOpts.add_argument('--apply',
                           action  = 'store_true',
                           dest    = 'apply',
                           help    = applyDoc,
                          )

    getOpts = parser.add_argument_group('get')
    getOpts.add_argument('--tfget',
                           action  = 'store_true',
                           dest    = 'tfget',
                           help    = tfgetDoc,
    )


    destroyOpts = parser.add_argument_group('destroy')
    destroyOpts.add_argument('--destroy',
                             action  = 'store_true',
                             dest    = 'destroy',
                             help    = destroyDoc,
                            )
    destroyOpts.add_argument('--force',
                             action  = 'store_true',
                             dest    = 'force',
                             help    = forceDoc,
                            )

    refreshOpts = parser.add_argument_group('refresh')
    refreshOpts.add_argument('--refresh',
                             action  = 'store_true',
                             dest    = 'refresh',
                             help    = refreshDoc,
                            )


    remoteOpts = parser.add_argument_group('remote')
    remoteOpts.add_argument('--remote-config',
                            action  = 'store_true',
                            dest    = 'remote',
                            help    = remoteDoc,
                           )

    remoteOpts.add_argument('--region',
                            action  = 'store',
                            dest    = 'region',
                            help    = regionDoc,
                           )

    planOpts = parser.add_argument_group('plan')
    planOpts.add_argument('--plan',
                          action  = 'store_true',
                          dest    = 'plan',
                          help    = planDoc,
                         )

    opts = parser.parse_args()

    msg = ''
    if (len(argv) < 2):
        printHelp(msg,parser)

    if ( (opts.apply   and opts.destroy) or
         (opts.apply   and opts.remote)  or
         (opts.destroy and opts.remote) ):
        msg = "--apply, --destroy, and --remote are mutually exclusive."

    if ( (opts.apply   and opts.region ) or
         (opts.destroy and opts.region ) or
         (opts.tfget   and opts.region ) ):
        msg = "--region may only be used with --remote"

    if (opts.force and not opts.destroy):
        msg = "--force can only be used with --destroy"

    if (opts.remote and not opts.region):
        msg = "--remote requires --region"

    if (opts.region and not opts.remote):
        msg = "--region requires --remote"

    if msg:
        printHelp(msg, parser)    
    return opts

def printHelp(msg, parser):
    if msg:
        print "\nERROR: ",msg,"\n"
    parser.print_help()
    sys.exit(1)

if __name__ == '__main__':
    sys.exit(main())

