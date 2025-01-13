provider "yandex" {
  token     = "YANDEX_CLOUD_TOKEN"
  cloud_id  = "CLOUD_ID"
  folder_id = "FOLDER_ID"
}

resource "yandex_compute_instance" "vm" {
  count = 2

  name = "nginx-instance-${count.index + 1}"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "*" 
    }
  }

  network_interface {
    subnet_id = "SUBNET_ID"
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
                #cloud-config
                packages:
                  - nginx
                runcmd:
                  - systemctl start nginx
                  - systemctl enable nginx
                EOF
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name = "nginx-lb"
  region = "ru-central1"
  
  listener {
    port     = 80
    protocol = "TCP"
    
  }

  healthcheck {
    port     = 80
    protocol = "HTTP"
    interval = 5
    timeout  = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
    path     = "/"
  }

  target_group {
    name = "nginx-target-group"

    target {
      subnet_id = "SUBNET_ID"
      instance_ids = [for vm in yandex_compute_instance.vm : vm.id]
    }
  }
}

output "load_balancer_ip" {
  value = yandex_lb_network_load_balancer.nlb.ip_address
}
