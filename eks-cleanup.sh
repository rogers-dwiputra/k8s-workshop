#!/bin/bash

# Set region, sesuaikan jika perlu
AWS_REGION="ap-southeast-3"

echo "🔍 Checking for orphan EIP..."
aws ec2 describe-addresses --region $AWS_REGION --query "Addresses[*].{PublicIp:PublicIp,AllocationId:AllocationId}" --output table

echo ""
echo "🧹 You can release EIP manually using:"
echo "aws ec2 release-address --allocation-id <AllocationId> --region $AWS_REGION"

echo ""
echo "🔍 Checking for orphan VPCs (non-default)..."
aws ec2 describe-vpcs --region $AWS_REGION --query "Vpcs[?IsDefault==\`false\`].[VpcId,CidrBlock]" --output table

echo ""
echo "🔍 Checking for orphan Subnets..."
aws ec2 describe-subnets --region $AWS_REGION --query "Subnets[*].[SubnetId,VpcId,CidrBlock,AvailabilityZone]" --output table

echo ""
echo "🔍 Checking for orphan Internet Gateways..."
aws ec2 describe-internet-gateways --region $AWS_REGION --query "InternetGateways[*].InternetGatewayId" --output table

echo ""
echo "🔍 Checking for orphan NAT Gateways..."
aws ec2 describe-nat-gateways --region $AWS_REGION --query "NatGateways[*].[NatGatewayId,State,SubnetId]" --output table

echo ""
echo "🔍 Checking for orphan Security Groups..."
aws ec2 describe-security-groups --region $AWS_REGION --query "SecurityGroups[?GroupName!='default'].[GroupId,GroupName,VpcId]" --output table

echo ""
echo "🔍 Checking for orphan IAM Roles (eksctl-related)..."
aws iam list-roles --query "Roles[?contains(RoleName, 'eksctl')].[RoleName,CreateDate]" --output table

echo ""
echo "🧹 You can delete IAM Role using:"
echo "aws iam delete-role --role-name <RoleName>"

echo ""
echo "🔍 Checking for orphan EC2 instances..."
aws ec2 describe-instances --region $AWS_REGION --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags]" --output table

echo ""
echo "🧹 You can terminate instance using:"
echo "aws ec2 terminate-instances --instance-ids <InstanceId> --region $AWS_REGION"

echo ""
echo "✅ DONE! Check above output and delete unused resources as needed."
