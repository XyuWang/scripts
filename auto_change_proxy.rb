#ruby

def get_ip
  puts '获取 IP...'
  `curl ip.cn 2> /dev/null`
end

def connect_vpn
  print '准备连接 vpn...'
  `networksetup -connectpppoeservice  linode_pptp`
  if $?.to_i == 0
    puts '成功'
    true
  else
    puts '失败'
    false
  end
end

def set_auto_proxy_off
  if auto_proxy_enabled?
    puts '关闭自动代理...'
    `networksetup -setautoproxystate Wi-Fi off`
  end
end

def set_atuo_proxy_on
  unless auto_proxy_enabled?
    puts '开启自动代理...'
    `networksetup -setautoproxyurl Wi-Fi http://127.0.0.1:54956/proxy.pac`
    `networksetup -setautoproxystate Wi-Fi on`
  end
end

def auto_proxy_enabled?
  result = `networksetup -getautoproxyurl Wi-Fi`
  result.include?("Enabled: Yes")
end


def socks_proxy_enabled?
  status = `networksetup -getsocksfirewallproxy  Wi-Fi`
  status.include? "Enabled: Yes"
end

def set_socks_proxy_on
  unless socks_proxy_enabled?
    puts '开启全局代理'
    `networksetup -setsocksfirewallproxy Wi-Fi 127.0.0.1 1081`
  end
end

def set_socks_proxy_off
  if socks_proxy_enabled?
    puts '关闭全局代理'
    `networksetup -setsocksfirewallproxy Wi-Fi 127.0.0.1 1081 off`
  end
end

def proxy_off!
  set_auto_proxy_on
  set_socks_proxy_off
end

def proxy_on!
  if socks_proxy_enabled?
    if auto_proxy_enabled?
      puts '检测到启动了全局代理, 准备关闭自动代理..'
      set_auto_proxy_off
    end
  else
    set_auto_proxy_on
  end
end


loop do
  ip = get_ip

  if ip.include? '116.192.14.209'
    unless connect_vpn
      puts '连接 VPN 失败, 等待重试...'
      sleep 20
      connect_vpn
    end

    sleep 5
    ip = get_ip
  end


  if ip.include?('日本') || ip.include?('美国')
    proxy_off!
  else
    proxy_on!
  end

  puts '等待一分钟'
  sleep 60
end
