#!/bin/bash

# Input parameters
AWS_PROFILE=`echo ${1}`
AWS_ACCOUNT_ID=`echo ${2}`
AWS_REGION=`echo ${3}`
SCRIPT=`basename "$0"`


usage()
{
    echo ""
    echo ""
    echo "Usage: ${SCRIPT} {AWS_PROFILE} {AWS_ACCOUNT_ID} {AWS_REGION} {CLOUD_FORMATION_STACK_NAME}"
    echo ""
    echo "   Eg: ./${SCRIPT} saas 908496931344 us-east-1 account_name so1 se1 si1"
    echo ""
    exit 0
}

[ $# -lt 4 ] && usage;

show_waiting_dots()
{
    PID=$!
    while [ -d /proc/$PID ]
    do
        sleep 10
        echo -n "."
    done
    echo ""
}

delete_stack()
{
    echo -e "Attempting to delete \e[34m$1\e[0m"
    if aws cloudformation describe-stacks --profile ${AWS_PROFILE} --region ${AWS_REGION} --stack-name $1 > /dev/null 2>&1; then
        echo "Deleting $1..."
        stack_delete_output=$(aws cloudformation delete-stack --profile ${AWS_PROFILE} --region ${AWS_REGION} --stack-name $1)
        if [ -z "$stack_delete_output" ]
        then
            stack_delete_wait=$(aws cloudformation wait stack-delete-complete --profile ${AWS_PROFILE} --region ${AWS_REGION} --stack-name $1) &
            show_waiting_dots;
            if aws cloudformation describe-stacks --profile ${AWS_PROFILE} --region ${AWS_REGION} --stack-name $1 > /dev/null 2>&1 ; then
                echo -e "\e[31mCould not delete everything in stack. Please delete $1 MANUALLY!\e[0m"
                exit 1;
            else
                echo -e "\e[32m$1 has been deleted\e[0m"
            fi;
        else
            echo "Moving on..."
        fi;
    else
        echo -e "\e[31mCould not find stack $1\e[0m"
        echo "Moving on..."
    fi;
}

delete_bucket()
{
    echo -e "Attempting to delete \e[34m$1\e[0m"
    if aws s3 ls --profile ${AWS_PROFILE} --region ${AWS_REGION} s3://$1 > /dev/null 2>&1; then
        echo "Deleting $1..."
        bucket_delete_output=$(aws s3 rb --profile ${AWS_PROFILE} --region ${AWS_REGION} s3://$1 --force)
        echo -e "\e[32mDeleted $1 Bucket\e[0m"
    else
        echo -e "\e[31mCould not find bucket $1\e[0m"
        echo "Moving on..."
    fi;
}

delete_rds_snapshot()
{
    echo "Finding rds snapshot associated with rds $1..."
    snapshot_id=$(aws rds describe-db-snapshots --profile ${AWS_PROFILE} --region ${AWS_REGION} --query 'DBSnapshots[?DBInstanceIdentifier==`'$1'`].DBSnapshotIdentifier' --output text)
    if [ "$snapshot_id" ]
    then
        echo -e "Attempting to delete rds snapshot with snapshot id \e[34m$snapshot_id\e[0m"
        rds_snapshot_delete_output=$(aws rds delete-db-snapshot --profile ${AWS_PROFILE} --region ${AWS_REGION} --db-snapshot-identifier $snapshot_id)
        if [ "$rds_snapshot_delete_output" ]
        then
            stack_delete_wait=$(aws rds wait db-snapshot-deleted --profile ${AWS_PROFILE} --region ${AWS_REGION} --db-snapshot-identifier $snapshot_id) &
            show_waiting_dots;
            echo -e "\e[32m$snapshot_id has been deleted\e[0m"
        else
            echo -e "\e[31mCould not delete rds snapshot with id $snapshot_id\e[0m"
            echo "Moving on..."
        fi;
    else
        echo -e "\e[31mCould not find any rds snapshots associated with rds $1\e[0m"
        echo "Moving on..."
    fi;
}

# Example for deleting any of the above AWS artifacts
delete_bucket $BUCKET_NAME

# Delete cloudformation stack
delete_stack $STACK_NAME


