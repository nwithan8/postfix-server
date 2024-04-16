from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)


@app.route('/send_email', methods=['POST'])
def send_email():
    data = request.json
    recipient = data.get('recipient')
    subject = data.get('subject')
    body = data.get('body')

    # Check if all required fields are present
    if not (recipient and subject and body):
        return jsonify({'error': 'Missing recipient, subject, or body in request'}), 400

    # Send email using Postfix
    try:
        # Prepare header hash
        subprocess.run(
            ['postmap', 'hash:/etc/postfix/sasl_passwd'],
            check=True
        )
        # Prepare sender rename
        subprocess.run(
            ['postmap', 'hash:/etc/postfix/smtp_header_checks'],
            check=True
        )
        # Reload Postfix
        subprocess.run(
            ['postfix', 'reload', '||', 'true'],
            check=True
        )
        # Send email
        subprocess.run(
            ['echo', f'{body}', '|', 'mail', '-s', f'{subject}', f'{recipient}'],
            check=True
        )
        return jsonify({'message': 'Email sent successfully'}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({'error': f'Failed to send email: {e.stderr}'}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
