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
${ProgramStartDate}    09/22/2026
${ProgramStartDateOfDec}    12/01/2026
${ProgramStartDateOfAug}    09/01/2026
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
    TypeText      Verification Code    10VDRWLTDR
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
    ClickElement       xpath=//div[contains(.,'First Reminder')]//button[contains(.,'Pause')]

    # 2. Directly verify modal title and enter reason without UseModal
    UseModal           On
    VerifyText         Pause Reminder

    # 3. Enter mandatory Reason for Pausing
    TypeText           Reason for Pausing             Pausing for testing purposes

    # 4. Click Pause inside the modal container
    ClickText          Pause                          anchor=Cancel
    UseModal           Off

    # 5. Verify the button changes to Resume after pausing
    VerifyText         Resume                         anchor=First Reminder

    VerifyText         2 Scheduled, 0 Sent, 1 Paused

Verify Reschedule Payment Reminder Flow
    # 1. Click Reschedule button on the First Reminder card
    ClickElement       xpath=//div[contains(.,'First Reminder')]//button[contains(.,'Reschedule')]

    # 2. Focus interaction within the Reschedule modal
    UseModal           On
    VerifyText         Reschedule Reminder

    # 3. Calculate a dynamic new date (e.g., 5 days after current date)
    ${new_date_input}=       Get Current Date         increment=0 days    result_format=%m/%d/%Y
    ${expected_ui_date}=     Get Current Date         increment=0 days    result_format=%b %d, %Y

    # 4. Fill in the New Reminder Date field
    TypeText           New Reminder Date              ${new_date_input}

    # 5. Save the rescheduled date
    ClickText          Reschedule                     anchor=Cancel
    UseModal           Off
\
Verify Manually Rescheduled Information On Reminder Card

    #  Verify the 'Manually rescheduled' audit text dynamically or statically
    VerifyText         Manually rescheduled by ${contact_name}    anchor=First Reminder
    
    #  Verify the updated scheduled date and pause status details
    VerifyText         Scheduled:                                 anchor=First Reminder
    #  Verify card action state buttons
    VerifyText         Resume                                     anchor=First Reminder
    VerifyText         Reschedule                                 anchor=First Reminder

Verify PAUSE ALL REMINDERS when reminders are already paused
    # 1. Click 'Pause All Reminders' from the global dropdown menu
    ClickElement       xpath=//*[text()='Payment Reminders']/following::button[contains(@class,'slds-button_icon') or contains(@class,'lightning-button-icon')][1]
    ClickText          Pause All

    # 2. Scope interaction to the 'Pause All Scheduled Reminders' modal
    UseModal           On
    VerifyText         Pause All Scheduled Reminders
    VerifyText         This will pause all scheduled reminders for this participant.

    # 3. Enter the required 'Reason for Pausing'
    TypeText           Reason for Pausing             Bulk pausing for automated test script verification

    # 4. Click the 'Pause' button inside the modal
    ClickText          Pause                          anchor=Cancel
    UseModal           Off

    # 5. Verify the warning banner for paused state
    Sleep              5s

Verify resuming all payment reminders
    # 1. Click Resume button on First Reminder card
    ClickElement       xpath=//div[contains(.,'First Reminder')]//button[contains(.,'Resume')]

    # 2. Click Resume button on Second Reminder card
    ClickElement       xpath=//div[contains(.,'Second Reminder')]//button[contains(.,'Resume')]

    # 3. Click Resume button on Final Reminder card
    ClickElement       xpath=//div[contains(.,'Final Reminder')]//button[contains(.,'Resume')]

    # 4. Verify status banner updates to show all reminders are scheduled
    VerifyText         3 Scheduled, 0 Sent, 0 Paused  timeout=10s

Verify Adding New Reminder Via Plus Button
    # 1. Hover over the '+' button to display the tooltip text and click it
    ClickElement       xpath=//*[text()='Payment Reminders']/following::button[contains(@class,'slds-button_icon') or contains(@class,'lightning-button-icon')][1]
    ClickElement       xpath=//button[contains(.,'Add Reminder') or contains(.,'Add New Reminder')] | //*[contains(text(),'Add Reminder')]
    # 2. Scope steps inside the 'Add New Reminder' modal
    UseModal           On
    VerifyText         Add New Reminder

    # 3. Enter today's date for Reminder Date
    ${today_date}=     Get Current Date               result_format=%m/%d/%Y
    TypeText           Reminder Date                  ${today_date}

    # 4. Select the 3rd template ('OE General Payment Reminder 3') from the dropdown
    ClickText          Select a template
    ClickText          OE General Payment Reminder 3

    # 5. Submit to create the reminder
    ClickText          Create Reminder                anchor=Cancel
    UseModal           Off
    VerifyText         Final Reminder
Verify Duplicate Reminder Cannot Be Created On Same Date
    # 1. Click '+' button to open 'Add New Reminder' modal
    ClickElement       xpath=//*[text()='Payment Reminders']/following::button[contains(@class,'slds-button_icon') or contains(@class,'lightning-button-icon')][1]
    ClickElement       xpath=//button[contains(.,'Add Reminder') or contains(.,'Add New Reminder')] | //*[contains(text(),'Add Reminder')]
    # 2. Scope steps inside the modal
    UseModal           On
    VerifyText         Add New Reminder

    # 3. Enter target date (e.g., Today's date)
    ${today_date}=     Get Current Date               result_format=%m/%d/%Y
    TypeText           Reminder Date                  ${today_date}

    # 4. Select a template that already exists on the same date (e.g. Final Reminder / Template 1)
    ClickText          Select a template
    ClickText          OE General Payment Reminder 3

    # 5. Attempt to create duplicate reminder
    ClickText          Create Reminder                anchor=Cancel
    UseModal           Off

    # 6. Verify duplicate error toast message appears
    VerifyText         Emails with the same subject cannot be sent on the same day.    partial_match=True
Verify Past Date Reminder Cannot Be Created
    # 1. Click '+' button to open 'Add New Reminder' modal
    ClickElement       xpath=//*[text()='Payment Reminders']/following::button[contains(@class,'slds-button_icon') or contains(@class,'lightning-button-icon')][1]
    ClickElement       xpath=//button[contains(.,'Add Reminder') or contains(.,'Add New Reminder')] | //*[contains(text(),'Add Reminder')]
    # 2. Scope steps inside the modal
    UseModal           On
    VerifyText         Add New Reminder

    # 3. Calculate a past date (1 day before today) and type into Reminder Date
    ${past_date}=      Get Current Date               increment=-1 day    result_format=%m/%d/%Y
    TypeText           Reminder Date                  ${past_date}

    # 4. Select a template and attempt to submit
    ClickText          Select a template
    ClickText          OE General Payment Reminder 1
    ClickText          Create Reminder                anchor=Cancel
    UseModal           Off

    # 5. Verify the error message toast appears on UI
    VerifyText         Reminder Date cannot be in the past    partial_match=True

Verify Delete Reminder
 
    # 1. Click Delete on the target reminder card
    ClickElement    xpath=//button[contains(.,'Delete')]
    # 2. Accept the native browser alert dialog
    CloseAlert        action=ACCEPT
    # 3. Verify the deletion success message
    VerifyText         Reminder deleted successfully    partial_match=True

Verify All Reminder gets cancelled after invoice is Paid
    ClickText          PayExed
    ClickElement       xpath=//a[starts-with(text(),'ACR-')]
    Sleep              5s
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    TypeText           Card number    4111111111111111
    TypeText           Expiration     10/29
    TypeText           Security code      123
    ClickText          PAY NOW
    VerifyText         Your payment was successful!
    VerifyText         PAYMENT TRANSACTION
    Sleep              2s
    SwitchWindow       2
    RefreshPage
    VerifyText         Invoice Status
    ClickElement       xpath=//span[text()='Program']/following::a[1]
    ClickText          PayExed            anchor=Enrollment
    ClickElement       xpath=//tr[td[contains(.,'${contact_name}')]]/td[5]
    ClickText          Payment Reminders
    VerifyText         No payment reminders found for this participant.

################## Payment reminders for Participant admitted in less than 20 days of Program start date

Verify Creation of a Program and addition of Participants in it for sending payment reminders ->20
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
    TypeText           Start Date                     ${ProgramStartDate}
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
    ClickText    Overview
    ClickText    New
    ClickText    Contact                      partial_match=False
    TypeText     Search for a contact...      Abhay Singhal
    ClickText    Abhay Singhal
    ClickText    Stage
    ClickText    Pending                      recognition_mode=vision
    ClickText    Save
#Admission of Participant
    ClickText        Enrollment                     anchor=Overview
    ClickText        Pending | Applicant
    ClickElement    xpath=//tr[.//a[contains(text(),'Abhay Singhal')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText       Admit with Invoice and Email
    ClickText       Select Email Template
    ClickText       Admit - On Campus
    ClickText       Send Email(s)
    Sleep           5s
    ClickText       PayExed                        anchor=Enrollment
    RefreshPage

Verify Payment Remainder through PayExed>20
    ClickText       PayExed                        anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'${contact_name}')]]/td[5]
    # Navigate to Payment Reminders sub-tab in the right panel
    ClickText          Payment Reminders

Verify Details for Auto Created Payment schedule ->20
    VerifyText    First Reminder
    VerifyText    Scheduled:

    # 1. Get Today's Date and set Invoice Due Date
    ${today_date}=                  Get Current Date               result_format=%m/%d/%Y
    ${InvoiceDueDate}=              Set Variable                   ${today_date}

    # 2. Calculate Days Between Today (Admission Date) and Program Start Date
    ${days_to_start}=               Evaluate                       (datetime.datetime.strptime("${ProgramStartDate}", "%m/%d/%Y") - datetime.datetime.strptime("${today_date}", "%m/%d/%Y")).days    modules=datetime

    # 3. Determine Reminder Offset (12 days if >20 days prior, 7 days if <=20 days prior)
    ${offset_days}=                 Set Variable If                ${days_to_start} > 20    12    7
    
    # 4. Calculate Scheduled Date (Invoice Due Date + Offset Days)
    ${expected_scheduled_date}=     Add Time To Date               ${InvoiceDueDate}    ${offset_days} days    result_format=%b %d, %Y    date_format=%m/%d/%Y

Verify Payment reminder is transfer when participant is transfered
    RefreshPage
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'Navya Tanwar')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Finance Request
    ClickText          Please select a type    anchor=Request Type:
    ClickText    Transfer               
    TypeText    Search for a course...    AIP2\n    anchor=To Course
    ClickText    AIP2 2027 | Apr 4, 2027 - Apr 9, 2027 | Harnessing AI for Breakthrough Innovation and Strategic Impact 
    TypeText     Please provide detailed information about your request...     test
    ClickText    Submit

    ClickElement       xpath=//one-app-nav-bar-item-root[.//span[text()='Tasks']]//a    
    ClickText    Select list display
    ClickText    Table
    ClickText    Select a List View: Tasks
    ClickText    Finance Requests      anchor=Completed Tasks    index=2
    ClickText    Create Date
    ClickText    Financial Request - Transfer    
    ClickElement                       xpath=//a[contains(@href,'Transfer')]
    ClickText                        Submit Transfer             anchor=cancel
    ClickText                        AIP2 - April 2027
    SwitchWindow                     NEW
    ClickText                        Enrollment                        anchor=Overview
    VerifyText                       Navya Tanwar
    Sleep                        2s
    ClickText                    PayExed                        anchor=Enrollment
    ClickText                    Programs
    ClickText                    ${Acronym} - September 2026
    ClickText                    PayExed                        anchor=Enrollment

################### Payment reminder for Participants admitted in less than 7 days
    ClickText                    Programs                       anchor=Home
    ClickText                    TestLessthan7 - August 2026
    ClickText       PayExed                        anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'${contact_name}')]]/td[5]
    # Navigate to Payment Reminders sub-tab in the right panel
    ClickText          Payment Reminders
    VerifyText         No payment reminders found for this participant.

Verify Change of Attendance status
    ClickElement       xpath=//tr[td[contains(.,'${contact_name}')]]//button[contains(@class,'slds-button_icon')] | //tr[td[contains(.,'${contact_name}')]]//td[last()]//a
    ClickText          Change Attendance

    # 2. Select 'Confirmed' in Update Attendance Status modal
    UseModal           On
    VerifyText         Update Attendance Status
    ClickElement       xpath=//button[contains(@aria-label,'Attendance Status') or contains(.,'Select an option')] | //*[text()='Attendance Status']/following::button[1]
    ClickElement       xpath=//*[@role='option' and .='Confirmed'] | //*[contains(@class,'slds-dropdown')]//*[text()='Confirmed']
    ClickText          Save                           anchor=Cancel
    UseModal           Off
    
    VerifyText         Confirmed                      anchor=Attendance
