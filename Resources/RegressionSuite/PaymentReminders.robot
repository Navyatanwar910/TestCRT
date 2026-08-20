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
    ClickText       PayExed                        anchor=Enrollment

Verify Payment Reminders on details tab
    ClickText    Details    anchor=Content
    ClickText    Financials    anchor=OE
    ScrollTo     ${contact_name}
    VerifyText             Do Not Send Auto-Payment Reminder Emails
    ClickText          Navya Tanwar                   anchor=Payment Reminders

Verify Details for Auto Created Payment schedule
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

    # 5. Verify Expected Scheduled Date in Salesforce UI
    VerifyText    ${expected_scheduled_date}    anchor=First Reminder

Verify Pause Payment Reminder
    # 1. Click Pause button on the First Reminder card
    ClickText          Pause                          anchor=First Reminder

    # 2. Scope interaction to the 'Pause Reminder' modal
    UseModal           On
    VerifyText         Pause Reminder

    # 3. Enter mandatory Reason for Pausing
    TypeText           Reason for Pausing             Pausing for testing purposes

    # 4. Click Pause inside the modal container
    ClickText          Pause                          anchor=Cancel
    UseModal           Off

    # 5. Verify the button changes to Resume after pausing
    VerifyText         Resume                         anchor=First Reminder

Verify Reschedule Payment Reminder Flow
    # 1. Click Reschedule button on the First Reminder card
    ClickText          Reschedule                     anchor=First Reminder

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

    # 6. Verify the updated date is updated on the reminder card
    VerifyText         ${expected_ui_date}            anchor=First Reminder

Verify Manually Rescheduled Information On Reminder Card
    # 1. Ensure focus on the specific participant's payment reminder card
    ScrollTo           Navya Tanwar

    # 2. Verify the 'Manually rescheduled' audit text dynamically or statically
    VerifyText         Manually rescheduled by ${contact_name}    anchor=First Reminder
    
    # 3. Verify the updated scheduled date and pause status details
    VerifyText         Scheduled:                                 anchor=First Reminder
    # 4. Verify card action state buttons
    VerifyText         Resume                                     anchor=First Reminder
    VerifyText         Reschedule                                 anchor=First Reminder

Verify Generate reminders Actions In Payment Reminders Global Dropdown

    # 1. GENERATE REMINDERS FOR ALL ADMIT PARTICIPANTS
    # Open the global Payment Reminders dropdown menu
    ClickElement       xpath=//*[text()='Payment Reminders']/following::button[contains(@class,'slds-button_icon') or contains(@class,'dropdown')][1]
    VerifyText         Generate Reminders for All Admit Participants
    ClickText          Generate Reminders for All Admit Participants

    # Confirm in modal
    UseModal           On
    VerifyText         Generate Payment Reminders
    VerifyText         This will create payment reminders for all participants in "Admit" status who don't already have scheduled reminders.
    ClickText          Generate                       anchor=Cancel
    UseModal           Off

    # Verify toast/warning message
    VerifyText         Success! All participants are up to date. No payment reminders were generated.    partial_match=True

    # ---------------------------------------------------------------------------------------------------------

Verify PAUSE ALL REMINDERS when reminders are already paused
    # 1. Click 'Pause All Reminders' from the global dropdown menu
    ClickElement       xpath=//*[text()='Payment Reminders']/following::button[contains(@class,'slds-button_icon') or contains(@class,'dropdown')][1]
    VerifyText         Pause All Reminders
    ClickText          Pause All Reminders

    # 2. Scope interaction to the 'Pause All Scheduled Reminders' modal
    UseModal           On
    VerifyText         Pause All Scheduled Reminders
    VerifyText         This will pause all scheduled reminders for this program.

    # 3. Enter the required 'Reason for Pausing'
    TypeText           Reason for Pausing             Bulk pausing for automated test script verification

    # 4. Click the 'Pause' button inside the modal
    ClickText          Pause                          anchor=Cancel
    UseModal           Off

    # 5. Verify the warning banner for paused state
    VerifyText         No scheduled reminders to pause    partial_match=True
    # ---------------------------------------------------------------------------------------------------------

Verify RESUME PAYMENT REMINDERS
    # Open the global dropdown menu once more
    ClickElement       xpath=//*[text()='Payment Reminders']/following::button[contains(@class,'slds-button_icon') or contains(@class,'dropdown')][1]
    VerifyText         Resume Payment Reminders
    ClickText          Resume Payment Reminders

    # Verify success banner message
    VerifyText         Payment reminders have been resumed. Past reminders were deleted, future reminders restored to Scheduled status.    partial_match=True

Verify Pausing all reminders
    # 1. Click 'Pause All Reminders' from the global dropdown menu
    ClickElement       xpath=//*[text()='Payment Reminders']/following::button[contains(@class,'slds-button_icon') or contains(@class,'dropdown')][1]
    VerifyText         Pause All Reminders
    ClickText          Pause All Reminders

    # 2. Scope interaction to the 'Pause All Scheduled Reminders' modal
    UseModal           On
    VerifyText         Pause All Scheduled Reminders
    VerifyText         This will pause all scheduled reminders for this program.

    # 3. Enter the required 'Reason for Pausing'
    TypeText           Reason for Pausing             Bulk pausing for automated test script verification

    # 4. Click the 'Pause' button inside the modal
    ClickText          Pause                          anchor=Cancel
    UseModal           Off

    # 5. Verify the warning banner for paused state
    VerifyText         Note: Program reminders are paused - newly created reminders have Paused status.    partial_match=True
Verify Delete Reminder And Recreate From Dropdown
 
    # 1. Click Delete on the target reminder card
    ClickText          Delete                         anchor=First Reminder

    # 2. Accept the native browser alert dialog
    CloseAlert        action=ACCEPT

    # 3. Verify the deletion success message
    VerifyText         Reminder deleted successfully    partial_match=True

    # 4. Verify whether the reminder is removed or if another card exists
    ${reminder_exists}=    IsText                     First Reminder
    Run Keyword If     '${reminder_exists}' == 'True'    VerifyText    First Reminder    anchor=Navya Tanwar

    # 5. Re-create a new reminder from the global dropdown menu
    ClickElement       xpath=//*[text()='Payment Reminders']/following::button[contains(@class,'slds-button_icon') or contains(@class,'dropdown')][1]
    VerifyText         Generate Reminders for All Admit Participants
    ClickText          Generate Reminders for All Admit Participants

    # 6. Confirm creation in modal
    UseModal           On
    VerifyText         Generate Payment Reminders
    ClickText          Generate                       anchor=Cancel
    UseModal           Off

    # 7. Verify newly generated reminder card exists on UI
    ScrollTo           Delete
    VerifyText         First Reminder                 anchor=Navya Tanwar

Verify Adding New Reminder Via Plus Button
    # 1. Hover over the '+' button to display the tooltip text and click it
    HoverElement       xpath=//button[contains(@class,'slds-button') and .//*[local-name()='svg' and @data-key='add']] | //*[text()='${contact_name}']/following::button[contains(.,'+') or contains(@title,'Add New Reminder')][1]
    ClickElement       xpath=//*[text()='${contact_name}']/following::button[contains(.,'+') or contains(@title,'Add New Reminder') or @title='Add New Reminder'][1]

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
    ClickElement       xpath=//*[text()='${contact_name}']/following::button[contains(.,'+') or contains(@title,'Add New Reminder') or @title='Add New Reminder'][1]

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
    ClickElement       xpath=//*[text()='${contact_name}']/following::button[contains(.,'+') or contains(@title,'Add New Reminder') or @title='Add New Reminder'][1]

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