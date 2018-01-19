import paypalrestsdk as pp
from flask import Flask
from flask import request
import requests
import os
import sys
import json

app = Flask(__name__)

# reduce logs to standard output  
import logging
log = logging.getLogger('werkzeug')
log.setLevel(logging.CRITICAL)

# get instance ip
r = requests.get('https://api.ipify.org?format=json')
data = r.json()
ip = data['ip']

if __name__ == "__main__":
    app.run()

# Create payment and configure paypal sdk. ARG0 is the price of the purchased item in the currency specified by ARG1. ARG0 is the first parameter passed to the oraclize_query, ARG1 is the second one.
pp.configure({
  "mode": "sandbox", # sandbox or live
  "client_id": "ARhkpXV_LYHKV51sXjvTlslgk4r2KmTwAiDbLCkTh6xlGjOfJ2ycixzD6eJK6w5_Wb3GkKX6GBs-8j85",
  "client_secret": "ECLxwuRHQA6ntAYYuDj2W87PAKuOHLYRwzrjuSC2jJdQWFzQA2qulZnJgzjux4BJjBQEamzOT4A5xXBy" })

payment = pp.Payment({
  "intent": "sale",
  "redirect_urls": {
      "return_url":"http://" + ip + ":8090/confirm_payment",
      "cancel_url":"http://" + ip + ":8090/cancel_payment"
   },
  "payer": {
    "payment_method": "paypal"
  }, 
 "transactions": [{
    "item_list": {
      "items": [{
        "name": "item",
        "sku": "item",
        "price": str(os.environ['ARG0']),
        "currency": str(os.environ['ARG2']),
        "quantity": str(os.environ['ARG1'])}]},
    "amount": {
      "total": int(os.environ['ARG0'])*int(os.environ['ARG1']),
      "currency": str(os.environ['ARG2'])},
    "description": "This is the payment transaction description." }]})

# To be called to shutdown the application 
def shutdown():
   func = request.environ.get('werkzeug.server.shutdown')
   func()

# It creates an API endpoint where the payment url can be fetched
@app.route("/create_payment")
def create():
    if payment.create():
        payment_id = payment.id;
        return payment.links[1].href
    else:
        return payment.error

# Confirm payment endopoint: called by paypal on payment confirmation received.
# It finalizes the payment on the merchant side, returning the status, payer_id, payment_id and payer_email
@app.route("/confirm_payment")
def confirm():
    payment_id = request.args.get('paymentId','')
    payer_id = request.args.get('PayerID','')
    payment = pp.Payment.find(payment_id)
    if payment.execute({"payer_id": payer_id}):
        f = open('/tmp/output','w')
        payer_email = payment.payer.payer_info.email
        data = {'status': 'received', 'payer_id': payer_id, 'payment_id': payment_id, 'payer_email': payer_email}
        f.write(json.dumps(data))
        shutdown()
        return 'Valid_Payment'
    else:
        data = {'status': 'failed', 'payer_id': payer_id, 'payment_id': payment_id}
        print(payment.error)
	return 'Error'

# Cancel payment API endpoint: called by paypal on payment failure
@app.route("/cancel_payment")
def cancel():
    payment_id = request.args.get('paymentId','')
    payer_id = request.args.get('PayerID','')
    data = {'status': 'failed', 'payer_id': payer_id, 'payment_id': payment_id, 'payer_email': payer_email}
    f.write(json.dumps(data))
    shutdown()
    return 'Cancel_Payment'
