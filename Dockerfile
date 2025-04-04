FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /root

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-setuptools git curl wget unzip build-essential \
    chromium-browser \
    && apt-get clean

# Install Go
RUN curl -OL https://go.dev/dl/go1.21.1.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

ENV PATH="/usr/local/go/bin:$PATH"

# Install Go tools
RUN go install github.com/lc/gau@latest
RUN go install github.com/tomnomnom/waybackurls@latest
RUN go install github.com/projectdiscovery/katana/cmd/katana@latest
RUN go install github.com/lc/subjs@latest

# Clone recon tools
RUN git clone https://github.com/xnl-h4ck3r/waymore.git /opt/waymore
RUN git clone https://github.com/0xsha/GoLinkFinder.git /opt/golinkfinder
RUN git clone https://github.com/GerbenJavado/LinkFinder.git /opt/LinkFinder
RUN git clone https://github.com/xnl-h4ck3r/xnLinkFinder.git /opt/xnLinkFinder
RUN git clone https://github.com/0x240x23elu/JSScanner.git /opt/JSScanner
RUN git clone https://github.com/m4ll0k/SecretFinder.git /opt/SecretFinder

# Install Python dependencies
COPY requirements.txt /opt/
RUN pip3 install -r /opt/requirements.txt

# Copy scripts
COPY full_recon.sh /usr/local/bin/full_recon.sh
COPY analyze_js.sh /usr/local/bin/analyze_js.sh
COPY run_all.sh /usr/local/bin/run_all.sh

RUN chmod +x /usr/local/bin/full_recon.sh /usr/local/bin/analyze_js.sh /usr/local/bin/run_all.sh

ENTRYPOINT ["/bin/bash"]
