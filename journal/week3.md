# Week 3 — Decentralized Authentication -- Andrew Brown


### Security considerations - Ashish
- Some common authentication methods
    - Traditional (username/passwprd)
    - OpenID Connect - using your exising social credentials (google, facebook, LinkedIn)
    - SAML/Single Sign On and IDP - using one credential for authenticating your apps
    
- Oauth: authorization

- Decentralized Authentication: Storing credentials at one location

- Amazon Cognito - allows authentication with credentils its store locally in your amazon account





- From your repo in Github, Launch Gitpod
- Log into your `aws console` using your IAM account - Refrain from using your root user for stuffs.

### Week 3 Video  Instruction

**Beware, there shall be a bit of coding**

- Creata a new user pool in aws cognito console
![]()

![]()

![]()

![]()

![]()

![]()

![]()


- to use the cognito library, we will use the aws amplify library for cognito [https://aws.amazon.com/amplify/?trk=66d9071f-eec2-471d-9fc0-c374dbda114d&sc_channel=ps&s_kwcid=AL!4422!3!646025317188!e!!g!!aws%20amplify&ef_id=Cj0KCQjwwtWgBhDhARIsAEMcxeAjuRaFLnlLXZVBxxCHiZTlNHT9GXvTQVtEM_WRr3RzDTZpLOWG2ZgaAhioEALw_wcB:G:s&s_kwcid=AL!4422!3!646025317188!e!!g!!aws%20amplify](https://aws.amazon.com/amplify/?trk=66d9071f-eec2-471d-9fc0-c374dbda114d&sc_channel=ps&s_kwcid=AL!4422!3!646025317188!e!!g!!aws%20amplify&ef_id=Cj0KCQjwwtWgBhDhARIsAEMcxeAjuRaFLnlLXZVBxxCHiZTlNHT9GXvTQVtEM_WRr3RzDTZpLOWG2ZgaAhioEALw_wcB:G:s&s_kwcid=AL!4422!3!646025317188!e!!g!!aws%20amplify)

[https://docs.amplify.aws/lib/auth/getting-started/q/platform/js/](https://docs.amplify.aws/lib/auth/getting-started/q/platform/js/)

-  First we need to install the aws amplify library, `cd ` into the frontend-ReactJs and execute the following:
```sh
    npm i aws-amplify --save
```

- You should now see `"aws-amplify": "^5.0.20"` in the `package.json`. The `--save` saves it in the `package.json`

- Now we go our `App.Js` import `amplify` and add the following:

```js
    import { Amplify } from 'aws-amplify';
```
```js
Amplify.configure({
  "AWS_PROJECT_REGION": process.env.REACT_APP_AWS_PROJECT_REGION,
  "aws_cognito_region": process.env.REACT_APP_AWS_COGNITO_REGION,
  "aws_user_pools_id": process.env.REACT_APP_AWS_USER_POOLS_ID,
  "aws_user_pools_web_client_id": process.env.REACT_APP_CLIENT_ID,
  "oauth": {},
  Auth: {
    // We are not using an Identity Pool
    // identityPoolId: process.env.REACT_APP_IDENTITY_POOL_ID, // REQUIRED - Amazon Cognito Identity Pool ID
    region: process.env.REACT_AWS_PROJECT_REGION,           // REQUIRED - Amazon Cognito Region
    userPoolId: process.env.REACT_APP_AWS_USER_POOLS_ID,         // OPTIONAL - Amazon Cognito User Pool ID
    userPoolWebClientId: process.env.REACT_APP_CLIENT_ID,   // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
  }
});
```

- Now we need to set our variables in our docker compose file under the frontend section
```yml

    REACT_APP_AWS_PROJECT_REGION: "${AWS_DEFAULT_REGION}" REACT_APP_AWS_COGNITO_REGION: "${AWS_DEFAULT_REGION}"
    REACT_APP_AWS_USER_POOLS_ID: "us-east-1_Ozdy7e7ef5"
    REACT_APP_CLIENT_ID: "6blah73674blahy673blah9"
```
**REACT_APP is needed to be bale to pass variable into REACT**
**Best Practice could be to pass the REACT_APP_CLIENT_ID as an enviornmnet variable**

- Now we will update our code to conditionally show components based on if we are logged in or out. We will start with the `HomeFeedPage.js`

```js
    import { Auth } from 'aws-amplify';

    const checkAuth = async () => {
    Auth.currentAuthenticatedUser({
      // Optional, By default is false. 
      // If set to true, this call will send a 
      // request to Cognito to get the latest user data
      bypassCache: false 
    })
    .then((user) => {
      console.log('user',user);
      return Auth.currentAuthenticatedUser()
    }).then((cognito_user) => {
        setUser({
          display_name: cognito_user.attributes.name,
          handle: cognito_user.attributes.preferred_username
        })
    })
    .catch((err) => console.log(err));
  }; 
```
- In our `ProfilInfo.js`, add the following:
```js
    import { Auth } from 'aws-amplify';

    const signOut = async () => {
    try {
        await Auth.signOut({ global: true }); // this forces every session to be signed out
        window.location.href = "/"
    } catch (error) {
        console.log('error signing out: ', error);
    }
  }
```

- Next we will implement our sign-in page `SigninPage.js` 

```js
    import { Auth } from 'aws-amplify';

    const onsubmit = async (event) => {
    setErrors('')
    console.log('onsubmit')
    event.preventDefault();
  
    Auth.signIn(email, password)
      .then(user => {
        localStorage.setItem("access_token", user.signInUserSession.accessToken.jwtToken)
        window.location.href = "/"
      })
      .catch(error => { 
        if (error.code == 'UserNotConfirmedException') {
          window.location.href = "/confirm"
        }
        setErrors(error.message) 
       });
        return false
  }
  
```

- Next, we need to creata user in our user pool

![]()

- We can see the confirmation status of our user is `Force change password`

- When we try to log in with the unconfrimed user, we get an error as shown below `Cannot read properties of null (reading 'accessToken')`

![]()

- Next, we will try to use `aws_cli` to confrim the user

```sh
    aws cognito-idp admin-set-user-password --username ibrahim --password blahblah! --user-pool-id us-east-1_odndu83765 --permanent
```
- Nowe, we should be able to sign into our Cruddur app with our username

![]()

- In our aws console, we can add attributes to our user to reflect in our app once we sign it as shown below 

![]()


- Next, we implement our Signup page. To do that, lets delete our already excisting or created user inside our userpool.

```js
    import { Auth } from 'aws-amplify';
    const onsubmit = async (event) => {
  event.preventDefault();
  setCognitoErrors('')
  try {
      const { user } = await Auth.signUp({
        username: email,
        password: password,
        attributes: {
            name: name,
            email: email,
            preferred_username: username,
        },
        autoSignIn: { // optional - enables auto sign in after user is confirmed
            enabled: true,
        }
      });
      console.log(user);
      window.location.href = `/confirm?email=${email}`
  } catch (error) {
      console.log(error);
      setCognitoErrors(error.message)
  }
  return false
}
```

- Next, we also update our confirmation page 
```js 
    import { Auth } from 'aws-amplify'
    
    const resend_code = async (event) => {
  setErrors('')
  try {
    await Auth.resendSignUp(email);
    console.log('code resent successfully');
    setCodeSent(true)
  } catch (err) {
    // does not return a code
    // does cognito always return english
    // for this to be an okay match?
    console.log(err)
    if (err.message == 'Username cannot be empty'){
      setErrors("You need to provide an email in order to send Resend Activiation Code")   
    } else if (err.message == "Username/client id combination not found."){
      setCognitoErrors("Email is invalid or cannot be found.")   
    }
  }
}

    const onsubmit = async (event) => {
  event.preventDefault();
  setErrors('')
  try {
    await Auth.confirmSignUp(email, code);
    window.location.href = "/"
  } catch (error) {
    setErrors(error.message)
  }
  return false
}
```
- Next, we try to sign up now confirm our email using the confirmation code sent to our email.

![]()

![]()

- We can see in the console that our user is confirmed and verified

![]()

- We can now sign in with your user and password 


- Next, we need to implement our recovery page so that we can recover our password if we lose it.

```js
    import { Auth } from 'aws-amplify';
    
    const onsubmit_send_code = async (event) => {
    event.preventDefault();
    setErrors('')
    Auth.forgotPassword(username)
    .then((data) => setFormState('confirm_code') )
    .catch((err) => setErrors(err.message) );
    return false
  }
  
  const onsubmit_confirm_code = async (event) => {
    event.preventDefault();
    setErrors('')
    if (password == passwordAgain){
      Auth.forgotPasswordSubmit(username, code, password)
      .then((data) => setFormState('success'))
      .catch((err) => setErrors(err.message) );
    } else {
      setErrors('Passwords do not match')
    }
    return false
  }
```


### Implementing Cognito JWT Server Side Verification
- The goal is to implement verification to secure our API endpoints on the backend. So First, we need to pass the header in our `HomeFeedPage.js`
```js
     headers: {
    Authorization: `Bearer ${localStorage.getItem("access_token")}`
  }
```
- Then we go to our backend folder and locate our `app.py`, we need to add the following

```python
    print(
    request.headers.get('Authorization')
)
```










