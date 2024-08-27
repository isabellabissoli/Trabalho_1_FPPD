FROM ubuntu:20.04

# Configurações de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

# Instalar dependências e SSH
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    vim \
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev \
    python3 \
    python3-pip \
    python3-mpi4py \
    openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Configurar SSH - Gerar e distribuir chaves SSH
RUN mkdir /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N "" \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && echo "Host *\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null" > /root/.ssh/config

# Start SSH service
RUN service ssh start

# Expor a porta 22 para SSH
EXPOSE 22

# Definir o diretório de trabalho
WORKDIR /home

# Copiar arquivos
COPY . .

# Iniciar o SSH e executar o script MPI com as opções para ignorar a verificação de chave do host
CMD service ssh start && mpirun --allow-run-as-root -np 3 --host master,slave1,slave2 \
    python3 mpi_ponto_a_ponto.py
