*** Settings ***
Documentation     Resource file for Data-Driven Testing of Stripe checkout scenarios.
...               Contains card test datasets (Success, Declines, 3DS) sourced from Stripe Docs.
Library           QWeb

*** Variables ***
# Default Common Card Fields (Stripe accepts any future date & valid CVC length)
${DEFAULT_EXP_DATE}    12/34
${DEFAULT_CVC}         123
${AMEX_CVC}            1234
${DEFAULT_ZIP}         12345

# -----------------------------------------------------------------------------
# STRIPE TEST CARDS DATASET (https://docs.stripe.com/testing)
# -----------------------------------------------------------------------------

# --- Standard Success Cards ---
${CARD_VISA_SUCCESS}               4242424242424242
${CARD_VISA_DEBIT}                 4000056655665556
${CARD_MASTERCARD}                 5555555555554444
${CARD_MASTERCARD_DEBIT}           5200828282828210
${CARD_AMEX}                       378282246310005
${CARD_DISCOVER}                   6011111111111117
${CARD_JCB}                        3566002020360505
${CARD_DINERS}                     3056930009020004
${CARD_UNIONPAY}                   6200000000000005

# --- Decline & Error Scenarios ---
${CARD_DECLINE_GENERIC}            4000000000000002
${CARD_DECLINE_INSUFFICIENT_FUNDS} 4000000000009995
${CARD_DECLINE_LOST}               4000000000009987
${CARD_DECLINE_STOLEN}             4000000000009979
${CARD_DECLINE_EXPIRED}            4000000000000069
${CARD_DECLINE_INCORRECT_CVC}      4000000000000127
${CARD_DECLINE_PROCESSING_ERROR}   4000000000000119
${CARD_DECLINE_FRAUDULENT}         4100000000000019

# --- 3D Secure (3DS) Authentication Cards ---
${CARD_3DS_REQUIRED}               4000002760003184
${CARD_3DS2_CHALLENGE}             4000000000003220

# --- Country-Specific Cards ---
${CARD_INDIA_VISA}                 4000003560000008
${CARD_JAPAN_VISA}                 4000003920000003
${CARD_MEXICO_VISA}                4000004840008001


*** Keywords ***
Process Payment Flow
    [Arguments]    ${card_number}    ${exp_date}=${DEFAULT_EXP_DATE}    ${cvc}=${DEFAULT_CVC}    ${zip}=${DEFAULT_ZIP}    ${expected_outcome}=Success
    [Documentation]    Reusable keyword to fill Stripe card details and verify expected payment outcome.
    
    # Fill in Card Fields (Adjust locators to match your application's input fields)
    TypeIntoText    xpath=//input[@name='cardnumber' or @id='card-number']    ${card_number}
    TypeIntoText    xpath=//input[@name='exp-date' or @id='exp-date']       ${exp_date}
    TypeIntoText    xpath=//input[@name='cvc' or @id='cvc']                 ${cvc}
    TypeIntoText    xpath=//input[@name='postal' or @id='postal']           ${zip}
    
    # Submit Payment
    ClickText       Pay
    
    # Verify Payment Result based on expected outcome
    Run Keyword If  '${expected_outcome}' == 'Success'              Verify Standard Success
    ...  ELSE IF    '${expected_outcome}' == 'Decline'              Verify Card Declined
    ...  ELSE IF    '${expected_outcome}' == 'Insufficient Funds'  Verify Insufficient Funds Error
    ...  ELSE IF    '${expected_outcome}' == '3DS'                  Verify 3D Secure Challenge Prompt

Verify Standard Success
    VerifyText      Payment Successful

Verify Card Declined
    VerifyText      Your card was declined.

Verify Insufficient Funds Error
    VerifyText      Your card has insufficient funds.

Verify 3D Secure Challenge Prompt
    VerifyElement   xpath=//iframe[contains(@src, 'hooks.stripe.com/redirect/3ds')]