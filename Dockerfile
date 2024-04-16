FROM ubuntu:latest
LABEL authors="Nate Harris"

# Need to update the package list first
RUN apt-get update -y

# Install all dependencies (other than postfix)
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get install curl python3 python3-pip -y

WORKDIR /app

# Install postfix
COPY postfix_install.sh /app/
RUN chmod +x postfix_install.sh
RUN ./postfix_install.sh

# Symlink the postfix config files
RUN rm /etc/postfix/main.cf || true
RUN ln -s /config/main.cf /etc/postfix/main.cf
RUN rm /etc/postfix/sasl_passwd || true
RUN ln -s /config/sasl_passwd /etc/postfix/sasl_passwd
RUN rm /etc/postfix/smtp_header_checks || true
RUN ln -s /config/smtp_header_checks /etc/postfix/smtp_header_checks

# Prepare additional postfix files
RUN mkdir -p /var/spool/postfix/etc/ || true
RUN cp /etc/host.conf /var/spool/postfix/etc/
RUN cp /etc/resolv.conf /var/spool/postfix/etc/
RUN cp /etc/services /var/spool/postfix/etc/

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

EXPOSE 5000

RUN chmod +x /app/entrypoint.sh
CMD ["/app/entrypoint.sh"]

