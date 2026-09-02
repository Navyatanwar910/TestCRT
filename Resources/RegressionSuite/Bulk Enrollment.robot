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
    TypeText      Verification Code    10VDRWLTDR
    ClickText     Verify
    VerifyText    Home
    ClickText     Programs             anchor=Home
Verify Finance Can Create A Valid Program
    [Documentation]    Verify CoreTech/Finance can create a valid program with all mandatory setup data and that the program is available for downstream enrollment and financial processing.

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

Verify setting up email template 
    [Documentation]    Test Case created using the QEditor
    
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
Verify Creation of Participant
    [Documentation]    Iterates through each contact name in the list to create 5 participants.
    
    # 1. Define list of 5 contacts
    @{CONTACT_NAME}=    Create List    Abhishek Mehta    Alok Gaur    Abhay Singhal
    
    # 2. Navigate to Overview once
    ClickText    Overview

    # 3. Loop directly over each item in the list
    FOR    ${contact}    IN    @{CONTACT_NAME}
        Log          Creating Participant for: ${contact}

        ClickText    New
        UseModal     On
        ClickText    Contact                    partial_match=False
        TypeText     Search for a contact...    ${contact}
        ClickText    ${contact}
        ClickText    Stage
        ClickText      Select an Option    anchor=*Stage
        ClickText    Pending                    recognition_mode=On               anchor=Stage
        ClickText    Save
        UseModal     Off

        # Allow record modal to save and clear before next iteration
        Sleep        2s
    END

Verify Bulk Enrollment with Invoice and email
    ClickText    Enrollment    anchor=Overview
    ClickCheckbox    Funnel | Tag | Date    on
    ClickText        Bulk Action
    ClickText        Admit with Invoice and Email
    ClickText    Select Email Template
    ClickText    Admit - On Campus
    ClickText    Send Email(s)
    RefreshPage
    ClickText    PayExed                    anchor=Enrollment
