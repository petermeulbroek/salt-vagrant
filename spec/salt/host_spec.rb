require "salt/host"
require "byebug"

RSpec.describe Salt::Host do
  before :each do
    @name = "myName"
    @info = {"ip" => "199.199.199.199"}
    @role_config = {"grains" => "tmp/myName"}
    
    @obj = Salt::Host.new(@name, @info, @role_config)
  end
  it "has a version number" do
    expect(Salt::Host::VERSION).not_to be nil
  end

  describe "#new" do
    it "can create an object" do
      expect( @obj ).to be_kind_of(Salt::Host)
    end
  end
  
  describe "#role" do
    it "reports role" do
      expect( @obj.role ).to eq('host')
    end
  end
  describe "#ip" do
    it "reports ip" do

      expect( @obj.ip ).to eq('199.199.199.199')
    end
  end
  context "generating keys" do
    describe "#keygen" do
      it "creates a key from default path" do
        expect{ @obj.keygen }.to_not raise_error(Exception)
        expect(File).to exist("keys/#{@name}/#{@name}.pub")
        expect(File).to exist("keys/#{@name}/#{@name}.pem")
      end
      
      it "creates a key from a non-default path" do
        @obj.keypath = "tmp"
        expect{ @obj.keygen }.to_not raise_error(Exception)
        expect(File).to exist("tmp/#{@name}.pub")
        expect(File).to exist("tmp/#{@name}.pem")
      end
      
    end
    describe "#pub_key" do
      it "reports public key location" do
        @obj.keypath = 'keys/myName'
        expect( @obj.pub_key ).to eql("keys/myName/myName.pub")
      end
    end
    describe "#pem_key" do
      it "reports private key location" do
        @obj.keypath = 'keys/myName'
        expect( @obj.pem_key ).to eql("keys/myName/myName.pem")
      end
      
    end
    #cleanup
    after(:all) do
      ["keys/myName", "tmp"].each do |p|
        ["pub", "pem"].each do |s|
          File.delete("#{p}/myName.#{s}") if File.exist?("#{p}/myName.#{s}")
        end
        Dir.rmdir(p) if File.directory?(p)
      end
    end
  end
  describe "#setDefaults" do
    before :each do
      @salt = double
      allow(@salt).to receive(:colorize=)
      allow(@salt).to receive(:grains_config=) { "bob" }
      allow(@salt).to receive(:minion_pub=)
      allow(@salt).to receive(:minion_key=)
    end
    it "should set defaults" do
      @obj.setDefaults(@salt)
    end
  end
end