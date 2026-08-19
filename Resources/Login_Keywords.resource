*** Settings ***
Library    QForce

*** Keywords ***
Login To Salesforce
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5YJXMZKRHI
    ClickText     Verify
    VerifyText    Home