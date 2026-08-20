*** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome
Suite Teardown          Close All Browsers

*** Variables ***
@{CONTACT_NAME}    Navya Tanwar    Anjali Kotawala    Aditya Ranjan Patro

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
    TypeText      Verification Code    5VKQODUZSH
    ClickText     Verify
    VerifyText    Home

Verify Creation of a Program and addition of Participants in it for sending payment reminders
# Generate timestamp and dynamic program name at runtime
    ${timestamp}=      Get Current Date               result_format=%Y%m%d-%H%M%S
    ${PROGRAM_NAME}=   Set Variable                   Program-Auto-${timestamp}
    ${Acronym}=        Set Variable                   ACR-${timestamp}
    Set Suite Variable    ${PROGRAM_NAME}
    Set Suite Variable    ${Acronym}

    ClickText          Programs                       anchor=Home
    ClickElement       xpath=//a[@title='New']
    VerifyText         New Program                    anchor=Cancel
    ClickText          Open Enrollment
    ClickText          Next
    TypeText           Program Name                   ${PROGRAM_NAME}
    TypeText           Acronym                        ${Acronym}
    TypeText           Start Date                     09/01/2026
    TypeText           End Date                       08/31/2027
    TypeText           Program Fee                    200000
    DropDown           Acceptance Criteria            Application/Admission
    DropDown           Program Status                 Confirmed
    ClickText          Save                           timeout=20s
    VerifyText         The Program was successfully created!
    ClickText          Finish
    Sleep              5s
    VerifyText         ${Acronym} - September 2026
# Generate random 4-digit number
    ${PROJECT_NUM}=    Evaluate    random.randint(1000, 9999)    modules=random
    Set Suite Variable             ${PROJECT_NUM}
    
    ClickText          Details    anchor=Content    recognition_mode=vision
    ClickText    Financials    anchor=OE
    ClickText    Edit PTA-Project Number
    TypeText     PTA-Project Number                 ${PROJECT_NUM}
    ClickText          --None--                       anchor=PTA-Award
    ClickText          EAFJY
    ComboBox    Search Invoice Templates...    Standard OE Invoice Template    index=1
    ClickText    Save
    ClickText    Admit Email
    ClickText    Admit Email Setup
    ClickText    Email Template  
    ClickText    Admit - On Campus
    ClickText    Save
#Addition of Participants
FOR    ${contact_name}    IN    @{CONTACT_NAMES}
        ClickText    Overview
        ClickText    New
        ClickText    Contact                      partial_match=False
        TypeText     Search for a contact...      ${contact_name}
        ClickText    ${contact_name}
        ClickText    Stage
        ClickText    Pending                      recognition_mode=vision
        ClickText    Save
END