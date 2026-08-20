*** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    QWeb
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome
Suite Teardown          Close All Browsers

*** Variables ***
${contact_name}    Navya Tanwar   
${ProgramStartDate}    09/01/2026
${ProgramStartDateOfDec}    12/01/2026
${ProgramStartDateOfAug}    08/22/2026
${InvoiceDueDate}    Get Current Date    result_format=%m%d%y

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
    TypeText      Verification Code    NY2UIUDIVN
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
    TypeText           Start Date                     ${ProgramStartDateOfDec}
    TypeText           End Date                       08/31/2027
    TypeText           Program Fee                    200000
    DropDown           Acceptance Criteria            Application/Admission
    DropDown           Program Status                 Confirmed
    ClickText          Save                           timeout=20s
    VerifyText         The Program was successfully created!
    ClickText          Finish
    Sleep              5s
    VerifyText         ${Acronym} - December 2026
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
    ClickText    Overview
    ClickText    New
    ClickText    Contact                      partial_match=False
    TypeText     Search for a contact...      ${contact_name}
    ClickText    ${contact_name}
    ClickText    Stage
    ClickText    Pending                      recognition_mode=vision
    ClickText    Save
#Admission of Participant
    ClickText        Enrollment                     anchor=Overview
    ClickText        Pending | Applicant
    ClickElement    xpath=//tr[.//a[contains(text(),'Navya Tanwar')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText       Admit with Invoice and Email
    ClickText       Select Email Template
    ClickText       Admit - On Campus
    ClickText       Send Email(s)
    Sleep           5s
    RefreshPage

Verify Payment Remainder through PayExed
    ClickText       PayExed                        anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'${contact_name}')]]/td[5]
    # Navigate to Payment Reminders sub-tab in the right panel
    ClickText          Payment Reminders

Verify Details for Auto Created Payment schedule
    [Documentation]    Calculates and verifies dates for First (+12d), Second (+31d), and Final (-28d) Reminders.

    # Get Today's Date and Set Invoice Due Date
    ${today_date}=                     Get Current Date               result_format=%m/%d/%Y
    ${InvoiceDueDate}=                 Set Variable                   ${today_date}

    # Calculate Days Between Today and Program Start Date
    ${days_to_start}=                  Evaluate                       (datetime.datetime.strptime("${ProgramStartDateOfDec}", "%m/%d/%Y") - datetime.datetime.strptime("${today_date}", "%m/%d/%Y")).days    modules=datetime

    # First Reminder Calculation (12 days if >20 days prior, 7 days if <=20 days prior)
    ${first_offset_days}=              Set Variable If                ${days_to_start} > 20    12    7
    ${expected_first_date}=            Add Time To Date               ${InvoiceDueDate}    ${first_offset_days} days    result_format=%b %-d, %Y    date_format=%m/%d/%Y

    #  Second Reminder Calculation (31 days after Invoice Due Date)
    ${expected_second_date}=           Add Time To Date               ${InvoiceDueDate}    31 days    result_format=%b %-d, %Y    date_format=%m/%d/%Y

    # Final Reminder Calculation (28 days before Program Start Date)
    ${expected_final_date}=            Subtract Time From Date        ${ProgramStartDateOfDec}    28 days    result_format=%b %-d, %Y    date_format=%m/%d/%Y

    # 7. UI Verification
    VerifyText                         First Reminder
    VerifyText                         ${expected_first_date}         anchor=First Reminder

    VerifyText                         Second Reminder
    VerifyText                         ${expected_second_date}        anchor=Second Reminder

    VerifyText                         Final Reminder
    VerifyText                         ${expected_final_date}         anchor=Final Reminder

Verify Pause Payment Reminder
    # 1. Click Pause on the First Reminder card
    ClickText          Pause                          anchor=First Reminder

    # 2. Directly verify modal title and enter reason without UseModal
    VerifyText         Pause Reminder
    TypeText           Reason for Pausing             Pausing first reminder for testing purpose
    
    # 3. Click the Pause button inside the overlay
    ClickText          Pause                          anchor=Cancel

    # 4. Verify status update on UI
    VerifyText         Paused                         anchor=First Reminder
    VerifyText         2 Scheduled, 0 Sent, 1 Paused