**** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    QWeb
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome


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
    TypeText      Verification Code    11KLAYEG2L
    ClickText     Verify
    VerifyText    Home
    ClickText     Programs             anchor=Home
    ClickText     ACR-20260820-132926 - December 2026
Verify Creation of Participant
    [Documentation]    Test Case created using the QEditor
    ClickText    Overview
    @{CONTACT_NAME}=    Create List    Aaditya Raut    A. Ahmed    Abhishek Mehta    Alok Gaur    Abhay Singhal    
    FOR    ${index}    IN RANGE    1    6
        Log          Creating Participant ${index} of 5
    ClickText    New
    ClickText    Contact    partial_match=False
    TypeText    Search for a contact...    ${CONTACT_NAME}
    ClickText                        ${CONTACT_NAME}
    ClickText    Stage
    ClickText    Pending                   recognition_mode=vision
    ClickText    Save
    END