#!/bin/bash

function mount_ebs_volume(){
      MOUNT_POINT="/opt/aem_test"
      AWS_REGION="ap-southeast-2"
      VOLUME_ID="vol-031ab78e"
      INSTANCE_ID=$(curl -s 169.254.169.254/2014-02-25/meta-data/instance-id)
      NEXT_WAIT_TIME=0
      VOLUME_TYPE="ext4"
      DEVICE="/dev/xvdh"
      PARTITION=$DEVICE+"1"
      NEXT_WAIT_TIME=0
      # FSTAB="false"
      if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p $MOUNT_POINT
      fi

      if [ -z "$INSTANCE_ID" ]; then
        echo "Instance ID could not be obtained"
        exit
      fi

      aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device $DEVICE --region $AWS_REGION

      until mount -t $VOLUME_TYPE $PARTITION $MOUNT_POINT || [ $NEXT_WAIT_TIME -eq 20 ]; do
      sleep $(( NEXT_WAIT_TIME++ ))
      done

      # if [ "$FSTAB" == "true" ]; then
      #     echo "$PARTITION $MOUNT_POINT $VOLUME_TYPE defaults 0 2" >> /etc/fstab
      # fi
}

mount_ebs_volume
