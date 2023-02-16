
# Week 0 — Billing and Architecture
With an awesome kick-off of the FREE AWS CLOUD PROJECT BOOTCAMP oganized by Andrew Brown, here is a detailed summary of my required activities in WEEK 0

## Week 0 - Live Streamed Video 
### CRUDDUR app purpose summary = Margaret 

Following my interview with Tony and successful hire as a cloud engineer, I finally got to meet the CRUDDUR team, investors and the fractional CTO to talk about the proposed project. The idea of an ephemeral microblogging social media platform with expired posts that foster trust and a safe place for authenticated and validated users to share and upload content without long-term tracking sounds cool. The target group while not defined with certainity yet lies between students or young professsionals. However, one certainty is that CRUDDUR is for anyone who deos not want to maintain a permanent presence online. 

### THE MEET
A short meeting with the team reveals an existing mock-up web application which was the basis of the marketing upon which this project is funded. The goal is to utilizie an existing Amazon Web Services (AWS) account to host CRUDDUR.
To foster resiliency, CRUDDUR will be architected as a microservice instead of a monolithic application to ensure separaion of several components such as user interface, business logic, data acess, etc., are not dependent on one another. Features will be delivered incrementally within sprints.
CRUDDUR would be developed using Javascript with React in its frontend and Python with Flask in its backend using API only. 
Investors are only concerned about budget (low cost as possible), on-time delivery (~14 weeks) and a platform that makes for a viable competitor for twitter.

### CRUDDUR'S ARCHIECTURAL DIAGRAM
Following consulting an expert (Chris), a comprehensive detail of architecture diagrams taking RRACs (Requirements, Risks, Assumption and Constraints) into account quickly helped us in identiying some RRACs for CRUDDUR.

**Requirements** = {ephemeral, looks like twitter, cost and time minded, verifiable, monitorable, traceable, feasible}

**Risks** = {Point of Failure, User adoption and engagement, unforseen circumstances}

**Assumptions** = {Available skills for the project, budget might be approved, engaged stakeholders throughout realization process}

**Constraints** = {ETA, Budget allocation, Vendor selection and limitations}.

Our expert recommended **TOGAF** and the **AWS Well-Architected Framework (AWS-WAF)** in building a secure, high-performing, resilient, and efficient infrastructure for CRUDDUR. A quick look at the AWS-WAF pillar pages looked overwhelming but a brief summary by OpenAI's Chatgpt helped out. Furthermore, a comprehensive review of the pillar is ongoing.

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/AWS%20WAF_1_chatgpt.png)

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/AWS%20WAF_2_chatgpt.png)

Now that we are ready to create our architectural diagram, we will leverage 3 types of designs:
- **Conceptual design** - Napkin diagram.

![ibrahim's napkin design](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/20230214_174643.jpg)

- **Logical design** - an illustration of how the system will be implemented without service names, SKUs or sizes.


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/AWS_Cruddur_Week0_Arch_Logical_Diagram%20(1).png)

[Lucid Chart share link](https://lucid.app/lucidchart/7f7c271e-68ec-449a-8bc3-a1ad8f3f536b/edit?viewport_loc=-281%2C69%2C2512%2C1242%2C0_0&invitationId=inv_217fa310-20c2-4a00-83e8-ad8d0364c705)


- **Physical design** - this illuatrates our infrastructure with details about each service, compute instances, IP addresses, connections, dependencies, etc.



### Setting MFA for Root and IAM Accounts, Creating an IAM User/ Role 
I took the following steps in setting up my MFA


- Click on "Users" and then "Add users"


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/creating%20user1.png)


- Enter the desired name, enable console access and choose your desired console password option


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/creating%20user2.png)


- I had already created an admin_Group with AdministrationAccess, so I just added my new user to the admin_Group


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/creating%20user3.png)


- Reviewed my choices and clicked create


- I can now see my newly created user in the User Console

![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/creating%20user4.png)


### Enabling MFA for my newly created user

- Click on the user


- Click on security credentials


- Under Multifactor authntication (MFA), choose "Assign MFA device"


- Give your device a name and choose your slect your an device of your choice, I choose Authentication app (Google Authenticator)


- Click show QR code and scan the QR code with your authenticator app 


- Enter the first MFA code


- Enter the second MFA code


- Click Add MFA.


You can now see your added MFA device for the user and its identifier.


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/creating%20user5.png)

### Using the CLI

Following Andrew Brown's follow-along video for setting up our Gitpod development space, I used the Cloud shell, I set up my environment, downloaded the `aws` cli, updated the `gitpod.yml` with aws cli install, and `gp env` my environmental variables so that I will not have to do an export everytime I log into Gitpod.

- Logged on to my GITPOD from my Github repo, installed aws cli using the command below:

`> `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"`

> `unzip awscliv2.zip`

> `sudo ./aws/install`


- Then I saved my environmental variables in gitpod for reusability


> `export AWS_ACCESS_KEY_ID=""`

> `export AWS_SECRET_ACCESS_KEY=""`

> `export AWS_DEFAULT_REGION=us-east-1`

The AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY were retrieved when I generated the credentials for my IAM user

> `gp env export AWS_ACCESS_KEY_ID=""`

> `gp env export AWS_SECRET_ACCESS_KEY=""`

> `gp env export AWS_DEFAULT_REGION=us-east-1`


- I used the below to get my Account ID and saved it as a variable in gitpod.

> `aws sts get-caller-identity --query Account --output text`

> `export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)`

> `gp env ACCOUNT_ID="123456789012"` 


- Executed the following command


`gitpod /workspace $ aws iam create`

> `aws iam create-user --user-name "Ibratest"`
    
    "User": {
        "Path": "/",
        "UserName": "Ibratest",
        "UserId": "XXXXXXXXXXXXXXXXXX",
        "Arn": "arn:aws:iam::123456789012:user/Ibratest", 
        "CreateDate": "2023-02-15T15:49:12+00:00"
        
    }`
    

- I could see my newly create user


- I added the user to the admin group using


> `aws iam add-user-to-group --group-name admin_Group --user-name Ibratest`



- Verified the user group using the following command 



> `aws iam list-groups-for-user --user-name Ibratest`
    
    "Groups": [
    
        {
            "Path": "/",
            "GroupName": "admin_Group",
            "GroupId": "XXXXXXXXXXXXXXXXXXXXX",
            "Arn": "arn:aws:iam::123456789012:group/admin_Group",
            "CreateDate": "2023-01-29T19:35:46+00:00"
        }
    ]




### Creating Budget and Billing Alarms 

#### On the Console (Following Chirags video)

- Logged on as root using my MFA


- Typed AWS Budget in the search bar


- Clicked Create Budget


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/budget1.png)


- Choose the budget type (use a template), and specified the template (Zerro spend Budget)


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/budget2.png)


- Named the budget and indicated the recipient when the set budget has exceeded its threshold


- Clicked on Create Budget. 


- Further, I also created an alert as indicated below:


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/budget3.png)


#### Using the CLI in GITPOD (Following Andrew's Video)



Using the aws CLI Command Reference Documentation

> `aws budgets create-budget \`

    --account-id $ACCOUNT_ID \
    --budget file://aws/json/budget.json \
    --notifications-with-subscribers file://aws/json/notifications-with-subscribers.json


I can now see both budgets created but since I will be billed after the 2nd Budget, I will the newly created budget.


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/budget4.png)



#### Billing Alarm
- To create a Billing Alarm, I had to create an SNS Topic using the following command:

            aws sns create-topic --name BootCamp_Billing_Alarm
           "TopicArn": "arn:aws:sns:us-east-1:123456789012:BootCamp_Billing_Alarm"

- The execution of the command returned a Topic ARN which will be used to create the SNS topic

        > aws sns subscribe \
            --topic-arn arn:aws:sns:us-east-1:123456789012:BootCamp_Billing_Alarm \
            --protocol email \
            --notification-endpoint ibrahimsaliu297@gmail.com

A confirmation was sent to my email as illustrated in the output o the CLI nd in my the console

        {
            "SubscriptionArn": "pending confirmation"
        }  


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/SNS1.png)


After confirmation, I can now see that my Subscription is verified on the console or via the cli using the command below: 
        > aws sns list-subscriptions


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/SNS2.png)


- I can now use my SNS Topic ARN in my Budegts 


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/SNS3.png)


#### To create an Metric Alarm in Cloud Watch via the CLI

- Created a json file "my_alarm.json" in my local repository based on the aws knowledge center documentation.


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Billing_alarm_1.png)


On the Console:
- Type Cloudwatch in the search bar

- Choose Alarms and Create


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Billing_alarm_2.png)


- Choose the desired metric


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Billing_alarm_3.png)

- Set your desired conditions 


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Billing_alarm_5.png)



- Configure your actions, I linked mine to an existing SNS_Topic I created earlier.


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Billing_alarm_6.png)


- Give your Alarm a name and description 


![](https://github.com/Ibrahim-saliu/aws-bootcamp-cruddur-2023/blob/main/my_resources/Billing_alarm_7.png)


- Review and Create Alarm




