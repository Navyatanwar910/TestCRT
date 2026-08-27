**** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    QWeb
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome

*** Variables ***
${RECIPIENT_LASTNAME}         Tanwar
${PROGRAM_NAME}               Program-Auto-20260827-120244 September 2026
${RECIPIENT_SALUTATION}       Ms.
${PROGRAM_DATES}              September 1, 2026 - August 31, 2027

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
    TypeText      Verification Code    ARPZFHFJ28
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
    @{CONTACT_NAME}=    Create List    A. Ahmed    Abhishek Mehta    Alok Gaur    Abhay Singhal
    
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
        ClickText      Select an Option    anchor=*Stage
        ClickText      Pending                    recognition_mode=On               anchor=Stage
        ClickText    Save
        UseModal     Off

        # Allow record modal to save and clear before next iteration
        Sleep        2s
    END

Verify Email Sent to Participant
    ClickText          Enrollment    anchor=Overview
    ClickText          Pending | Applicant
    ClickElement       xpath=//tr[.//a[contains(text(),'Navya Tanwar')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText    Admit with Invoice and Email
    ClickText    Select Email Template
    ClickText    Admit - On Campus
    ClickText    Send Email(s)
    ClickText    PayExed             anchor=Enrollment
    ClickText       PayExed                        anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'Navya Tanwar')]]/td[5]
    # 1. Switch to Activity tab
    ClickText          Activity                       anchor=Contact Highlights

Verify Activity Email Subject And Body Against Template
    [Documentation]    Opens the sent email entry in the Activity timeline and verifies merge fields.

    # 1. Locate and expand the target email entry in the Activity timeline
    ClickText        Acceptance: ${RECIPIENT_LASTNAME}    anchor=August 2026
    
    # 2. Verify Subject Line (Matches: Acceptance: {{{Recipient.LastName}}}: {{{Invoice__c.Program__c}}} ...)
    VerifyText       Acceptance: ${RECIPIENT_LASTNAME}: ${PROGRAM_NAME}

    # 3. Verify Salutation & Greeting
    VerifyText       Dear ${RECIPIENT_LASTNAME},
    
    # 4. Verify Body Content & Dynamic Paragraphs
    VerifyText       Congratulations! We are pleased to inform you of your acceptance to ${PROGRAM_NAME}
    VerifyText       which will be held on the Stanford campus from ${PROGRAM_DATES}.
    VerifyText       Attached is your letter of acceptance from
    VerifyText       Please confirm your attendance in the program by replying to this email.
    
    # 5. Verify Payment Section
    VerifyText       Payment:
    VerifyText       To secure your place in the program, please remit payment per the invoice within 30 days.
    VerifyText       To submit a credit card payment:
    
    # 6. Verify Closing Paragraphs & Signature
    VerifyText       Logistics:
    VerifyText       Congratulations again on your acceptance! The Stanford GSB Executive Education experience is a powerful catalyst for transformative change — in yourself, your company, and your career. It is designed to challenge your thinking, inspire growth, and connect you with a collaborative network of global business leaders. We look forward to welcoming you to the Stanford campus where our goal is to change lives, change organizations, and change the world.