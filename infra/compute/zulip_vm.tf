resource "google_compute_address" "public_loadbalencer_ip" {
  name    = "zulip-loadbalancer-ip"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "zulip_vm" {
  name         = "zulip-vm"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      type  = "pd-ssd"
      size  = "50"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
      nat_ip = google_compute_address.public_loadbalencer_ip.address
    }
  }
  
  #metadata_startup_script = "sudo apt-get update && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>Avenue Code is the leading software consulting agency focused on delivering end-to-end development solutions for digital transformation across every vertical. We pride ourselves on our technical acumen, our collaborative problem-solving ability, and the warm professionalism of our teams.!</h1></body></html>' | sudo tee /var/www/html/index.html"
  #metadata = {
  #    startup_script = file("/Users/hemant/work/zulip/infra/compute/startup.sh")
  #}
  #metadata_startup_script = <<SCRIPT
  #  sudo apt-get update
  #  sudo apt-get install git -y
  #  sudo apt-get install docker.io -y
  #  sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  #  sudo chmod +x /usr/local/bin/docker-compose
  #  cd ~/
  #  mkdir work
  #  cd work
  #  git clone https://github.com/zulip/docker-zulip
  #  cd docker-zulip
  #  sed -i 's/SETTING_EXTERNAL_HOST: "localhost.localdomain"/SETTING_EXTERNAL_HOST: "35.200.217.44"/g' docker-compose.yml
  #  sudo docker-compose up -d --build
  #SCRIPT
  metadata_startup_script = <<SCRIPT
    sudo apt-get update
    sudo apt-get install git -y
    cd $(mktemp -d)
    curl -fLO https://download.zulip.com/server/zulip-server-latest.tar.gz
    tar -xf zulip-server-latest.tar.gz
    ./zulip-server-*/scripts/setup/install --certbot --email=contact@superdatacity.com --hostname=app.superdatacity.com
  SCRIPT
  
  
  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["https-server"]
}

resource "google_compute_firewall" "https-server" {
  name    = "default-allow-https-terraform"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  // Allow traffic from everywhere to instances with an https-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}