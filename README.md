## 1. Log in to the AWS Console (image1.png)

1. Navigate to the console sign-in URL: <https://sparta-devops.signin.aws.amazon.com/console>
2. Enter your assigned **username** and **password**.
3. Click the **Sign In** button to access the console.

## 2. Launch an Instance (image2.png)

1. Open the EC2 Launch Instance wizard using the following link: <https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#LaunchInstances:>

### 2.1. Name and Tags

* In the **Name** field, enter: `se-{your first name}-finalproject`
  * _Example: If your name is John, enter `se-john-finalproject`_

### 2.2. Application and OS Images (Amazon Machine Image)

1. Click on the **Ubuntu** image icon.
2. Select **Ubuntu 24.04 LTS** from the dropdown list.
3. Confirm that the selection is updated.

### 2.3. Instance Type

* From the **Instance type** dropdown list, select **t3.micro**.

### 2.4. Key Pair (Login)

1. Click the **Create new key pair** link.
2. In the **Key pair name** field, enter: `se-{your first name}-finalproject`
3. Click **Create key pair**.
4. **Important:** Save the downloaded `.pem` file to a secure location on your local computer.

### 2.5. Network Settings

* Locate the **Network settings** section.
* Check the box next to **Allow HTTP traffic from the internet**.

### 2.6. Finalize Launch

* Review your settings on the right-hand side summary panel.
* Click the **Launch instance** button to provision the server.

## 3. Upload and run the app deploy script via SSH

### 3. 1. Locate the Instance

1. Navigate to the EC2 Instances dashboard
  <https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#Instances:v=3;$case=tags:true%5C,client:false;$regex=tags:false%5C,client:false>
2. Use the search bar (find instance textbox) to locate your previously created instance (image3.png).
3. Click on the **Instance ID** in the table to view the instance details.

### 3. 2. Set .pem File Permissions

Before connecting, ensure your key file has the correct permissions.

**On Windows:** Open PowerShell and run the following commands (replace `se-{your first name}-finalproject` with your actual pem filename):
``` powershell
icacls.exe se-{your first name}-finalproject.pem /reset
icacls.exe se-{your first name}-finalproject.pem /grant:r "$($env:username):(r)"
icacls.exe se-{your first name}-finalproject.pem /inheritance:r
```
**On Linux:** Open a terminal and run the following command (replace `se-{your first name}-finalproject` with your actual pem filename):
```bash
chmod 400 "se-{your first name}-finalproject.pem"
```
### 3. 3. Connect and Upload

1. **Connect to your instance** using the SSH command. Replace the placeholder with your instance's public DNS (e.g., `ec2-34-251-55-16.eu-west-1.compute.amazonaws.com`):
```bash
ssh -i "se-{your first name}-finalproject.pem" ubuntu@{instance's public dns}
```
2. Type `yes` to continue connecting to the instance.
3. Once connected, type `exit` to return to your local machine's terminal.
4. **Upload the `finalproject.sh` script** to the instance using SCP:
```bash
scp -i "se-{your first name}-finalproject.pem" finalproject.sh ubuntu@{instance's public dns}:/home/ubuntu
```
### 3. 4. Run the Deployment Script

1. Re-connect to your instance via SSH
```bash
ssh -i "se-{your first name}-finalproject.pem" ubuntu@{instance's public dns}
```
2. Add execute permissions to the script:
```bash
chmod +x finalproject.sh
```
3. Run the script to deploy the app:
```bash
./finalproject.sh
```
### 3.5 Verification

Open a web browser and navigate to your instance's public IP address or DNS name on port 80 (HTTP) to confirm the application is accessible:

## 4. Create AIM image (image4.png)

1. On the **Instance details** page, click on the **Actions** button (top right).
2. Select **Image and templates**, then click the **Create image** submenu.

### 4.1. Configure Image Name

* In the **Image name** field, enter: `se-{your first name}-img`

### 4.2. Finalize Creation

* Click the **Create image** button (bottom right).

## 5. Create Launch Templates (image5.png)

### 5.1. Get Security Group ID

1. On your **Instance details** page, click on the **Security** tab.
2. Note the **Security Group ID** (e.g., `sg-06086d6a22797a57b`).

### 5.2. Navigate to Launch Templates

1. Open the Create Template page: <https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#CreateTemplate:>

### 5.3. Name and Description

* In the **Launch template name** field, enter: `se-{your first name}-lt`

### 5.4. Application and OS Images

* Click on the **My AMIs** tab.
* Select the AMI image you created in Section 4.

### 5.5. Key Pair

* In the **Key pair (login)** section, select the key pair created in step 2.4.

### 5.6. Network Settings

* In the **Network settings** section, select **Select existing security group**.
* Choose the security group ID you noted in step 5.1.

### 5.7. Create Template

* Click the **Create launch template** button (right side).

## 6. Auto Scaling and Load balancing

### Step 1: Configure Group

1. Open the Create Auto Scaling page: <https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#CreateAutoScalingGroup:>
2. In the **Auto Scaling group name** field, enter: `se-{your first name}-as`
3. Select your **Launch template** (created in step 5.3) from the list.
4. Click on the **Next** button.

### Step 2: Choose Availability Zones

1. In the **Availability Zones and subnets** section, select all available options from the list.
2. Click on the **Next** button.

### Step 3: Configure Load Balancing

1. Under **Load balancing**, select **Attach to a new load balancer**.
2. Change the **Load balancer name** to: `se-{your first name}-as-lt`
3. Ensure **Load balancer scheme** is set to **Internet-facing**.
4. Under **Default routing (forward to)**, select **Create a target group**.
5. Change the **New target group name** to: `se-{your first name}-as-lt-tg`
6. Check the box for **Turn on Elastic Load Balancing health checks**.
7. Click on the **Next** button.

### Step 4: Configure Group Size and Scaling

1. Set **Desired capacity** to `2`.
2. Set **Min desired capacity** to `2`.
3. Set **Max desired capacity** to `4`.
4. Select **Target tracking scaling policy**.
5. Click on the **Next** button.

### Step 5: Add Notifications (Optional)

1. Add notifications if required, otherwise skip.

### Step 6: Add Tags

1. Click **Add tag**.
2. **Key:** `Name`
3. **Value:** `se-{your first name}-app-HA-SC`
4. Click on the **Next** button.

### Step 7: Review and Create

1. Review all settings on the summary page.
2. Click on the **Create Auto Scaling group** button.

### Verification

1. Navigate to the Load Balancers page: <https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#LoadBalancers:>
2. Find your load balancer named `se-{your first name}-as-lt`.
3. Click on the load balancer name.
4. Wait until the **Status** changes from `Provisioning` to `Active` (see image6.png).
5. Verify your application is running by navigating to the load balancer's **DNS name** in your web browser (e.g., `se-otto-as1-lt2-2144247013.eu-west-1.elb.amazonaws.com`).
