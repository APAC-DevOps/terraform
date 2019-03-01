import boto3
import pytz
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from datetime import tzinfo
import time

#created by Jianhua WU jianhua.wu@yrgrp.com on 2016 May 16th
#a python script for backing up AWS EBS volume and for deleting AWS EBS volume, by default, the

aws_ec2 = boto3.client('ec2')
#startrack_aem_data_snapshots = boto3.resource('ec2')

def delete_aws_snapshots(snapshot_ownerid,snapshot_timezone,snapshot_retain_day,filters_values):
    if snapshot_retain_day < 3:
        print('You should not delete snapshots from 3-day ago. You might end up with no restorable copy in your AWS')
        exit()

    describe_startrack_aem_data_volume_snapshots = aws_ec2.describe_snapshots(
        OwnerIds = [ snapshot_ownerid ],
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': filters_values
            }
        ]
    )

    my_total_snapshots = len(describe_startrack_aem_data_volume_snapshots['Snapshots'])
    print(my_total_snapshots)
    for my_snapshots in range(len(describe_startrack_aem_data_volume_snapshots['Snapshots'])):
        if int(str(datetime.now(timezone(snapshot_timezone)).date()).replace('-','')) - int(str(describe_startrack_aem_data_volume_snapshots['Snapshots'][my_snapshots]['StartTime'])[0:10].replace('-','')) > snapshot_retain_day:
            print('Attention: deleting snapshot ',describe_startrack_aem_data_volume_snapshots['Snapshots'][my_snapshots]['SnapshotId'])
            response_ec2_delete_snapshot = aws_ec2.delete_snapshot(
                SnapshotId= describe_startrack_aem_data_volume_snapshots['Snapshots'][my_snapshots]['SnapshotId']
            )
            if response_ec2_delete_snapshot['ResponseMetadata']['HTTPStatusCode'] == 200:
                print("Info: Snapshot response_ec2_delete_snapshot['SnapshotId'] deleted successfully")
            else:
                print('Warn: Snapshot delete operation failed')





def create_aws_snapshots(aws_volume_ids,aws_snapshot_tags):
    if len(aws_volume_ids) != len(aws_snapshot_tags):
        print('Error: the quantity of volume ids does not match the quantity of snapshot tags. Please fix the issue and run the program again')
        exit()
    for index_id in range(len(aws_volume_ids)):
        create_startrack_aem_data_volume_snapshot = aws_ec2.create_snapshot(
            VolumeId = aws_volume_ids[index_id],
            Description = "make snapshot for startrack aem server's data volume"
        )

        aws_ec2.create_tags(
            Resources = [ create_startrack_aem_data_volume_snapshot['SnapshotId'] ],
            Tags=[
                {
                    'Key': 'Name',
                    'Value': aws_snapshot_tags[index_id]
                }
            ]
        )

        if create_startrack_aem_data_volume_snapshot['SnapshotId']:
            print('Info: Snapshot', create_startrack_aem_data_volume_snapshot['SnapshotId'], 'created successfully')
        else:
            print('Fatal: Snapshot creation failed')

#call create_aws_snapshots(volumeid)
create_aws_snapshots(aws_volume_ids = ['vol-ba135970','vol-9da20a5a'],aws_snapshot_tags = ['STARTRACK_AEM_DATA_VOLUME','KELLOGG_AEM_DATA_VOLUME'])
#delete_aws_snapshots(ownerid,timezone,retain_days_of_snapshots)
delete_aws_snapshots(snapshot_ownerid = '014461671789',snapshot_timezone = 'Australia/Sydney',snapshot_retain_day = 7,filters_values = [ 'AEM_DATA_Volume_20160513', 'STARTRACK_AEM_DATA_VOLUME', 'KELLOGG_AEM_DATA_VOLUME', 'STARTRACK_AEM_MANUAL_BACKUP_20160518'])
