**** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    QWeb
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome

*** Variables ***
${TEST_PROGRAM_NAME}    ACR-20260902-161359 - September 2026

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
    TypeText      Verification Code    3JQHOZY4LY
    ClickText     Verify
    VerifyText    Home
    ClickText     Programs             anchor=Home

Verify Default Workspace Tabs and ListView Pin
    [Documentation]    Verifies default top-level navigation tabs and pinned list view on Programs page.
    # Verify default workspace tabs
    VerifyText          Home
    VerifyText          Programs
    VerifyText          Contacts
    VerifyText          Companies
    VerifyText          Tasks
    VerifyText          Reports
    VerifyText          Recalculation Manager
    VerifyText          Split Invoice Templates List

    # Navigate to Programs & Verify 'Recently Viewed' list view is pinned
    ClickText           Programs
    VerifyText          Recently Viewed
    VerifyElement       xpath=//button[contains(@title,'Unpin') or contains(@class,'is-pinned')]

Verify Program Record Top-Level Header Fields
    [Documentation]    Navigates to a program record and checks top-level summary header fields.
    ClickText           ${TEST_PROGRAM_NAME}
    
    # Verify top-level program header fields
    VerifyText          Program Type                    anchor=Program
    VerifyText          Program Date Range              anchor=Program
    VerifyText          Program Fee                     anchor=Program
    VerifyText          Upcoming App Deadline           anchor=Program
    VerifyText          Final Deadline                  anchor=Program

Verify Main Program Navigation Tabs
    [Documentation]    Verifies main record tabs are displayed as applicable.
    VerifyText          Overview                        anchor=Program Type
    VerifyText          Enrollment                      anchor=Overview
    VerifyText          PayExed                         anchor=Enrollment
    VerifyText          Financials                      anchor=PayExed
    VerifyText          Content                         anchor=Financials
    VerifyText          Details                         anchor=Content
    VerifyText          System                          anchor=Details

Verify Program Overview List Sections
    [Documentation]    Verifies Overview tab sections and lists.
    ClickText           Overview                        anchor=Program Type
    VerifyText          Program Funnel
    VerifyText          Registered Participants
    VerifyText          Pending and Waitlist
    VerifyText          Cancellations
    VerifyText          Transfers
    VerifyText          Rejections
    VerifyText          Program Staff
    VerifyText          Instructors
    VerifyText          Guests
    VerifyText          Other Members

Verify Clicking Funnel Count Opens Corresponding Contacts on tab
    [Documentation]    Clicks on a non-zero count in Program Funnel table to verify drill-down behavior.
    # Click count under Transfers column (value 1 in screenshot)
    ClickText           1                               anchor=Transfer
    # Verify contact record details render in table below
    VerifyText          Abhay Singhal                   anchor=Transfers

Verify Enrollment Subtabs
    [Documentation]    Verifies subtabs available under the Enrollment tab.
    ClickText           Enrollment                      anchor=Overview
    VerifyText          Pending/Waitlist                anchor=Export to CSV
    VerifyText          To Admit                        anchor=Pending/Waitlist
    VerifyText          Admitted                        anchor=To Admit
    VerifyText          Reject                          anchor=Admitted
    VerifyText          Cancel                          anchor=Reject
    VerifyText          Transfer                        anchor=Cancel

Verify PayExed Subtabs
    [Documentation]    Verifies payment tracking subtabs under the PayExed tab.
    ClickText           PayExed                         anchor=Enrollment
    VerifyText          All                             anchor=Export to CSV
    VerifyText          Paid                            anchor=All
    VerifyText          In Transit                      anchor=Paid
    VerifyText          Unpaid                          anchor=In Transit
    VerifyText          30 O/D                          anchor=Unpaid
    VerifyText          60 O/D                          anchor=30 O/D
    VerifyText          90 O/D                          anchor=60 O/D
    VerifyText          No Response                     anchor=90 O/D
    VerifyText          No Commitment                   anchor=No Response

Verify Financials Subtabs in Program
    [Documentation]    Verifies subtabs under Financials tab.
    ClickText           Financials                      anchor=PayExed
    VerifyText          Invoices                        anchor=System
    VerifyText          Cancels                         anchor=Invoices
    VerifyText          Faculty Payments                anchor=Cancels
    VerifyText          Expenses                        anchor=Faculty Payments

Verify Content Tab Sections
    [Documentation]    Verifies schedules and session sections under Content tab.
    ClickText           Content                         anchor=Financials
    VerifyText          Schedules: Grid & Daily
    VerifyText          First Session Date
    VerifyText          Last Session Date
    VerifyText          Program Sessions
    VerifyText          Material Items

Verify Details Tab Subtabs and Layout
    [Documentation]    Verifies subtabs and field groups under the Details tab.
    ClickText           Details                         anchor=Content
    
    # Verify subtabs under Details
    VerifyText          General                         anchor=Details
    VerifyText          OE                              anchor=General
    VerifyText          Financials                      anchor=OE
    VerifyText          Admit Email                     anchor=Financials
    VerifyText          Participant Site                anchor=Admit Email
    VerifyText          Certificate                     anchor=Participant Site

    # Verify General Subtab Sections & Fields
    VerifyText          Program Details
    VerifyText          Program Name
    VerifyText          Cohort Name
    VerifyText          Acronym
    VerifyText          Program Root Label
    VerifyText          Start Date
    VerifyText          End Date
    VerifyText          Program Type
    VerifyText          Program Status
    
    VerifyText          Additional Details
    VerifyText          Module Information
    VerifyText          Module Details

Verify Program Highlights Right Sidebar Panel
    [Documentation]    Verifies data card fields displayed in Program Highlights sidebar panel.
    VerifyText          Program Highlights              anchor=Activity
    VerifyText          Program Info
    VerifyText          Program Name
    VerifyText          Budget Enrollment
    VerifyText          Current Enrollment
    VerifyText          Module Count
    VerifyText          PTA
    VerifyText          Active
    VerifyText          Cancelled
    VerifyText          Faculty Directors & Staff
