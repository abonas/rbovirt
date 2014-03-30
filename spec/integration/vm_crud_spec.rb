require "#{File.dirname(__FILE__)}/../spec_helper"

shared_examples_for "Basic VM Life cycle" do

  before(:all) do
    @cluster = @client.clusters.last.id
    @template_id = "00000000-0000-0000-0000-000000000000"
    name = 'vm-'+Time.now.to_i.to_s
    @vm = @client.create_vm(:name => name, :template => @template_id, :cluster => @cluster)
    @client.add_volume(@vm.id)
    @client.add_interface(@vm.id, :network_name => @network_name)
    while !@client.vm(@vm.id).ready? do
    end
  end

  after(:all) do
    @client.destroy_vm(@vm.id)
  end

  it "test_should_create_template" do
    template_name = "tmplt-"+Time.now.to_i.to_s
    template = @client.create_template(:vm => @vm.id, :name => template_name, :description => "test_template")
    template.class.to_s.should eql("OVIRT::Template")
    while !@client.vm(@vm.id).ready? do
    end
    @client.destroy_template(template.id)
  end

  it "test_should_return_a_template" do
    @client.template(@blank_template_id).id.should eql(@blank_template_id)
  end

  it "test_should_return_a_vm" do
    @client.vm(@vm.id).id.should eql(@vm.id)
  end

  it "test_should_start_and_stop_vm" do
    @client.vm_action(@vm.id, :start)
    while !@client.vm(@vm.id).running? do
    end
    @client.vm_action(@vm.id, :shutdown)
  end

  it "test_should_set_vm_ticket" do
    @client.vm_action(@vm.id, :start)
    while !@client.vm(@vm.id).running? do
    end
    @client.set_ticket(@vm.id)
    @client.vm_action(@vm.id, :shutdown)
  end

  it "test_should_destroy_vm" do
    name = 'd-'+Time.now.to_i.to_s
    vm = @client.create_vm(:name => name, :template =>@blank_template_id, :cluster => @cluster)
    @client.destroy_vm(vm.id)
  end

  it "test_should_update_vm" do
    name = 'u-'+Time.now.to_i.to_s
    @client.update_vm(:id => @vm.id, :name=> name, :cluster => @cluster)
  end

  it "test_should_create_a_vm" do
    name = 'c-'+Time.now.to_i.to_s
    vm = @client.create_vm(:name => name, :template => @blank_template_id, :cluster => @cluster)
    vm.class.to_s.should eql("OVIRT::VM")
    @client.destroy_vm(vm.id)
  end
end

describe "Admin API VM Life cycle" do

  before(:all) do
    user, password, url, datacenter, @network_name = endpoint
    opts = {:datacenter_id => datacenter, :ca_cert_file =>  "#{File.dirname(__FILE__)}/../ca_cert.pem"}
    @client = ::OVIRT::Client.new(user, password, url, opts)
  end

  context 'admin basic vm and templates operations' do
    it_behaves_like "Basic VM Life cycle"
  end
end

describe "User API VM Life cycle" do

  before(:all) do
    user, password, url, datacenter, @network_name = endpoint
    opts = {:datacenter_id => datacenter,
            :ca_cert_file =>  "#{File.dirname(__FILE__)}/../ca_cert.pem",
            :filtered_api => support_user_level_api}
    @client = ::OVIRT::Client.new(user, password, url, opts)
  end

  context 'user basic vm and templates operations' do
    it_behaves_like "Basic VM Life cycle"
  end
end