*** Settings ***
Documentation     Resource file for Data-Driven Testing of Stripe checkout scenarios.
...               Contains card test datasets (Success, Declines, 3DS) sourced from Stripe Docs.
Library           QWeb

*** Test Cases ***
Login To Salesforce Instance
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    MTQGAWBDPC
    ClickText     Verify
    VerifyText    Home
    ClickText     Programs             anchor=Home
    ClickText     ACR-20260820-132926 - December 2026