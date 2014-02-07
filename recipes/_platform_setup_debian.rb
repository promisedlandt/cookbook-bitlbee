# Sadly, the default Docker Ubuntu image doesn't include the universe / multiverse repositories.
if platform?("ubuntu")
  apt_repository "universe" do
    uri "http://archive.ubuntu.com/ubuntu/"
    components ["universe"]
    distribution node[:lsb][:codename]
  end

  apt_repository "multiverse" do
    uri "http://archive.ubuntu.com/ubuntu/"
    components ["multiverse"]
    distribution node[:lsb][:codename]
  end
end

include_recipe "apt"
