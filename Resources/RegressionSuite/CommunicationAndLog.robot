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
${ProgramStartDateOfDec}    12/01/2026
${search_term}    Acceptance: Tanwar
${email_subject}    Acceptance: Tanwar: Program-Auto-20260820-132926 December 2026
${expected_status}  Sent
${contact_name}    Navya Tanwar
${task_subject}    Call
${contact_name}       Navya Tanwar
${attendance_status}  Confirmed


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
    ClickText     ACR-20260820-132926 - December 2026                          
Verify Payment Remainder through PayExed
    ClickText       PayExed                        anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'${contact_name}')]]/td[5]
    # 1. Switch to Activity tab
    ClickText          Activity                       anchor=Contact Highlights
Verify Activity Tab Functionality
    # Test Refresh and verify success toast notification
    ClickElement       xpath=//a[contains(text(),'Refresh') or contains(.,'Refresh')] | //button[contains(.,'Refresh')]
    VerifyText         Data refreshed successfully    timeout=10s

    # Test Search functionality
    TypeText           Search subject or body         ${search_term}
    VerifyText         ${search_term}                 timeout=5s
    Sleep              5s
    # Clear search input
    TypeText           Search subject or body         ${EMPTY}

    # 5. Expand individual activity timeline items
  #  ScrollTo           Navya Tanwar had a payment
  #  ClickElement       xpath=//*[text()='August 2026']/following::a[contains(.,'Payment -')][1] | //*[text()='August 2026']/following::button[contains(@class,'slds-button_icon')][1]
   # VerifyText         Amount                         timeout=5s
  #  Sleep              5s

    # 6. Test Collapse All / Expand All toggle
    ${is_collapse_present}=                           IsText    Collapse All    timeout=3s
    IF    ${is_collapse_present}
        ClickText      Collapse All
        VerifyText     Expand All                     timeout=5s
        ClickText      Expand All
    ELSE
        ClickText      Expand All
        VerifyText     Collapse All                   timeout=5s
    END
    
Verify Email Status In Activity Tab
    # 1. Option 1: Direct text verification anchored to the specific email subject
    VerifyText         ${expected_status}             anchor=${email_subject}

    # 2. Option 2: XPath element verification to ensure status badge exists next to the email entry
    VerifyElement      xpath=//*[contains(text(),'${email_subject}')]/following::*[text()='${expected_status}'][1]


Create Log Note And Verify In Activity Tab
    # 1. Open the participant row dropdown on PayExed tab and click 'Log Notes'
    ClickElement       xpath=//tr[td[contains(.,'${contact_name}')]]//button[contains(@class,'slds-button_icon')] | //tr[td[contains(.,'${contact_name}')]]//td[last()]//a
    ClickText          Log Notes

    # 2. Fill out the Create Note modal
    UseModal           On
    VerifyText         Create Note

    TypeText           Subject                        ${task_subject}
    ClickText          --None--                       anchor=Task Subtype
    ClickElement       xpath=//*[@role='option' and .='Call'] | //lightning-base-combobox-item[contains(.,'Call')] | //*[contains(@class,'slds-dropdown')]//*[text()='Call']
    ClickText          Save                           anchor=Cancel
    UseModal           Off

    # 3. Verify success toast notification
    VerifyText         Task "Call" was created.       timeout=10s

    # 4. Refresh Activity tab and verify created task item appears
    ClickText          Activity                       anchor=Contact Highlights
    ClickElement       xpath=//*[text()='Activity']/following::a[contains(text(),'Refresh')][1] | //a[text()='Refresh']

    # 5. Verify the created task exists under Activity timeline
    VerifyText         ${task_subject}                anchor=${contact_name} had a task

Change Attendance Status And Verify On Invoice Page
    # 1. Open the action menu for Navya Tanwar row and select Change Attendance
    ClickElement       xpath=//tr[td[contains(.,'${contact_name}')]]//button[contains(@class,'slds-button_icon')] | //tr[td[contains(.,'${contact_name}')]]//td[last()]//a
    ClickText          Change Attendance

    # 2. Select 'Confirmed' in Update Attendance Status modal
    UseModal           On
    VerifyText         Update Attendance Status
    ClickElement       xpath=//button[contains(@aria-label,'Attendance Status') or contains(.,'Select an option')] | //*[text()='Attendance Status']/following::button[1]
    ClickElement       xpath=//*[@role='option' and .='${attendance_status}'] | //*[contains(@class,'slds-dropdown')]//*[text()='${attendance_status}']
    ClickText          Save                           anchor=Cancel
    UseModal           Off

    # 3. Click the ACR invoice link under Navya Tanwar
    ClickElement       xpath=//a[contains(text(),'ACR-')]

    # 4. Verify Communication Status is updated to Confirmed on the Invoice page
    VerifyField        Communication Status           Confirmed