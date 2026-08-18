*** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome
Suite Teardown          Close All Browsers

*** Test Cases ***
Login as Admin User
    [Documentation]    login in Salesforce
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