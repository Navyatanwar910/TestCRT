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
    TypeText      Verification Code    F0M5KKN75K
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
    @{CONTACT_NAME}=    Create List    Navya Tanwar    A. Ahmed    Abhishek Mehta    Alok Gaur    Abhay Singhal
    
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

    @{CONTACT_NAME}=    Create List    Navya Tanwar    A. Ahmed    Abhishek Mehta    Alok Gaur    Abhay Singhal

    ClickText          Enrollment    anchor=Overview
    FOR    ${contact}    IN    @{CONTACT_NAME}
        ClickText          Pending | Applicant
        ClickElement       xpath=//tr[.//a[contains(text(),'${contact}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]        ClickText    Admit with Invoice and Email
        ClickText    Select Email Template
        ClickText    Admit - On Campus
        ClickText    Send Email(s)
        Sleep        3s
    END
    RefreshPage
    ClickText    PayExed             anchor=Enrollment
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

Verify Deferral Admit email Template
    ClickText        Programs                        anchor=Home
    ClickText        ${Acronym}
    ClickText        PayExed                        anchor=Enrollment
    ClickElement       xpath=//tr[.//a[contains(text(),'Abhay Singhal')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Send Email
    ClickText    Select Email Template
    ClickText    Deferral Admit
    ClickText    Send Email(s)
    Sleep        3s
    ClickText    PayExed             anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'Abhay Singhal')]]/td[5]
    # 1. Switch to Activity tab
    ClickText          Activity      anchor=Contact Highlights    
    # 1. Locate and expand the target email entry in the Activity timeline
    ClickText        Acceptance: Singhal    anchor=August 2026
    
    # 2. Verify Subject Line (Matches: Acceptance: {{{Recipient.LastName}}}: {{{Invoice__c.Program__c}}} ...)
    VerifyText       Acceptance: Singhal: ${PROGRAM_NAME}

    # 3. Verify Salutation & Greeting
    VerifyText       Dear
    VerifyText       As a result of deferring your participation in the ${PROGRAM_NAME}
    VerifyText       I wanted to provide an updated letter of acceptance for the program to be held from
    VerifyText       Attached is a letter of acceptance from . Please confirm your attendance in the program by replying to this email.
    VerifyText       Please also make sure to note the entire duration of the program on your calendar.

    # 3. Verify Payment Section & Pay Hyperlink
    VerifyText       To secure your space in the program, please remit payment per the attached invoice within 30 days.
    VerifyText       Your place in the program will be confirmed upon receipt of payment.
    VerifyText       To submit a credit card payment, please use the following link:
    
    # Assert existence of the clickable 'Pay' link
    VerifyElement    xpath=//a[text()='Pay']

    # 4. Verify Additional Details & FAQ Hyperlink
    VerifyText       Additional Details:
    VerifyText       Please also click
    VerifyText       to reference a list of answers to frequently asked questions regarding our programs.
    
    # Assert existence of the clickable 'here' link
    VerifyElement    xpath=//a[text()='here']

    # 5. Verify Closing & Sign-off
    VerifyText       Congratulations again on your acceptance.
    VerifyText       Please feel free to contact me directly should you have any questions regarding the program.
    VerifyText       We look forward to your participation!
    VerifyText       Sincerely,

Verify Auto Enroll email Template
    ClickText        Programs                        anchor=Home
    ClickText        ${Acronym}
    ClickText        PayExed                        anchor=Enrollment
    ClickElement       xpath=//tr[.//a[contains(text(),'Abhay Singhal')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Send Email
    ClickText    Select Email Template
    ClickText    Auto-Enroll
    ClickText    Send Email(s)
    Sleep        3s
    ClickText    PayExed             anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'Abhay Singhal')]]/td[5]
    # 1. Switch to Activity tab
    ClickText          Activity      anchor=Contact Highlights    
    
    # 2. Verify Subject Line (Matches: Acceptance: {{{Recipient.LastName}}}: {{{Invoice__c.Program__c}}} ...)
    ClickText         Secure Your Spot: Payment Details Enclosed for ${PROGRAM_NAME}

    # 3. Verify Salutation & Greeting
    VerifyText       Dear
    VerifyText       We look forward to your participation in
    VerifyText       To secure your place and ensure a smooth start, please review the following important information regarding your payment and our cancellation policy.

    # 2. Payment Link Section
    VerifyText       Payment Link
    VerifyText       Payment is due within 30 days of receipt of invoice.
    VerifyText       If the invoice is received within 45 days of the start date, payment is due upon receipt.
    VerifyText       You can submit your payment via credit or debit card through this secure link:

    # Verify presence of the hyperlinked payment URL
    VerifyElement    xpath=//a[contains(@href,'pay') or contains(text(),'Pay')]

    # 3. Cancellation and Deferral Policy Section
    VerifyText       Cancellation and Deferral Policy
    VerifyText       We are unable to offer refunds or cancellation for 
    VerifyText       Before the program start date 
    # 4. Next Steps Section
    VerifyText       Next Steps
    VerifyText       Submit your payment to secure your spot in 
    VerifyText       Once we have received your full payment, you will receive access to the online learning management system on 
    # 5. Closing & Signature
    VerifyText       We look forward to embarking on this learning journey with you!
    VerifyText       Sincerely,

Verify Waitlist email Template
    ClickText        Programs                        anchor=Home
    ClickText        ${Acronym}
    ClickText        PayExed                        anchor=Enrollment
    ClickElement       xpath=//tr[.//a[contains(text(),'Abhay Singhal')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Send Email
    ClickText    Select Email Template
    ClickText    Waitlist
    ClickText    Send Email(s)
    Sleep        3s
    ClickText    PayExed             anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'Abhay Singhal')]]/td[5]
    # 1. Switch to Activity tab
    ClickText          Activity      anchor=Contact Highlights    
    
    # 2. Verify Subject Line (Matches: Acceptance: {{{Recipient.LastName}}}: {{{Invoice__c.Program__c}}} ...)
    ClickText         Singhal: Your Application to Stanford University Executive Education

    # 2. Salutation & Opening Paragraph
    VerifyText       Dear 
    VerifyText       Thank you for your application to 
    VerifyText       I am writing to inform you that the Admissions Committee has carefully reviewed your application
    VerifyText       and would like to offer you a place on the waitlist for the
    VerifyText       While admission is not guaranteed at this time, we will consider candidates from the waitlist should spaces become available.
    VerifyText       Kindly inform us within 1 week of receiving this email if you wish to be added to the waitlist.

    # 3. Decision Context Paragraph
    VerifyText       We approach admission decisions with great care, considering factors such as program objectives,
    VerifyText       diversity of professional experience, and geography.
    VerifyText       This outcome is not a reflection of your accomplishments but a result of our limited enrollment capacity.

    # 4. Closing & Signature
    VerifyText       We appreciate your patience and hope to welcome you to the program soon.
    VerifyText       Thank you again for your interest in Stanford’s Executive Education programs.
    VerifyText       While I am unable to provide feedback on individual applications, please email me should you have any questions about the waitlist process or the program.
    VerifyText       Sincerely,

Verify Reject - Deferral email Template
    ClickText        Programs                        anchor=Home
    ClickText        ${Acronym}
    ClickText        PayExed                        anchor=Enrollment
    ClickElement       xpath=//tr[.//a[contains(text(),'Abhay Singhal')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Send Email
    ClickText    Select Email Template
    ClickText    Reject
    ClickText    Send Email(s)
    Sleep        3s
    ClickText    PayExed             anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'Abhay Singhal')]]/td[5]
    # 1. Switch to Activity tab
    ClickText          Activity      anchor=Contact Highlights    
    
    # 2. Verify Subject Line (Matches: Acceptance: {{{Recipient.LastName}}}: {{{Invoice__c.Program__c}}} ...)
    ClickText         Singhal: Your Application to Stanford University Executive Education    anchor=1

    VerifyText       Dear 
    VerifyText       Thank you for your application to ${PROGRAM_NAME} program 
    VerifyText       Our Admissions Committee has carefully reviewed your application
    VerifyText       and regrets that we cannot offer you a place in the 
    VerifyText       The selection process this year has been extremely competitive due to the large number of applications received from highly qualified candidates.

    # 3. Defer Offer Details Paragraph
    VerifyText       We'd like to offer you acceptance into the 
    VerifyText       and kindly ask that you let us know your decision regarding this offer within two weeks of receiving this email.
    VerifyText       Your early confirmation will greatly assist us in planning and ensuring a diverse and dynamic group of participants.

    # 4. Closing & Sign-off
    VerifyText       Should you have any questions or require further information, please do not hesitate to reach out.
    VerifyText       I look forward to hearing from you.
    VerifyText       Sincerely,