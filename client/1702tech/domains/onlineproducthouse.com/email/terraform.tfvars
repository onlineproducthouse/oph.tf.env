client_info = {
  region                 = "eu-west-1"
  project_name           = "onlineproducthouse.com"
  project_short_name     = "oph"
  service_name           = "email"
  service_short_name     = "email"
  environment_name       = "shared"
  environment_short_name = "shared"
}

sg_sender_auth = [
  {
    type  = "CNAME",
    host  = "url4367.onlineproducthouse.com",
    value = "sendgrid.net"
  },
  {
    type  = "CNAME",
    host  = "22274710.onlineproducthouse.com",
    value = "sendgrid.net"
  },
  {
    type  = "CNAME",
    host  = "em9398.onlineproducthouse.com",
    value = "u22274710.wl211.sendgrid.net"
  },
  {
    type  = "CNAME",
    host  = "s1._domainkey.onlineproducthouse.com",
    value = "s1.domainkey.u22274710.wl211.sendgrid.net"
  },
  {
    type  = "CNAME",
    host  = "s2._domainkey.onlineproducthouse.com",
    value = "s2.domainkey.u22274710.wl211.sendgrid.net"
  },
  {
    type  = "TXT",
    host  = "_dmarc.onlineproducthouse.com",
    value = "v=DMARC1; p=none; fo=0; adkim=s; aspf=s"
  },
]
