require 'pairtree'
require 'fileutils'
require 'tmpdir'


RSpec.describe HathiTrust::Pairtree do

  let(:idmap) do
    {
      'uc1.c3292592'             => 'sdr1/obj/uc1/pairtree_root/c3/29/25/92/c3292592',
      'loc.ark:/13960/t9w09k00s' => 'sdr1/obj/loc/pairtree_root/ar/k+/=1/39/60/=t/9w/09/k0/0s/ark+=13960=t9w09k00s',
      'ia.ark:/13960/t9w10cs7x'  => 'sdr1/obj/ia/pairtree_root/ar/k+/=1/39/60/=t/9w/10/cs/7x/ark+=13960=t9w10cs7x'
    }
  end

  def make_paths(idmap)
    idmap.values.each do |subdir|
      dir = @tmpdir + subdir
      FileUtils.mkdir_p(dir)
      root   = @tmpdir + Pathname.new(subdir.split('/')[0..2].join('/'))
      prefix = subdir.split('/')[2]
      File.open(root + 'pairtree_prefix', 'w:utf-8') do |pp|
        pp.print(prefix + '.')
      end
      File.open(root + 'pairtree_version0_1', 'w:utf-8') {}
    end
  end

  around(:each) do |example|
    Dir.mktmpdir do |d|
      @tmpdir = Pathname.new(d)
      FileUtils.mkdir_p(@tmpdir + "sdr1/obj")
      example.run
    end
  end

  it "has a version number" do
    expect(HathiTrust::Pairtree::VERSION).not_to be nil
  end

  it "translates names into directories" do
    make_paths(idmap)
    pt = HathiTrust::Pairtree.new(root: @tmpdir + 'sdr1/obj')

    idmap.each_pair do |id, dir|
      expect(pt.path_for(id).to_s).to eq((@tmpdir + dir).to_s)
    end
  end

  describe "#create" do
    let(:pt) { HathiTrust::Pairtree.new(root: @tmpdir + 'sdr1/obj') }

    it "can create new object directories" do
      expect {pt.create('test.something', new_namespace_allowed: false)}.to raise_error(HathiTrust::Pairtree::NamespaceDoesNotExist)
      expect(pt.create('test.something', new_namespace_allowed: true).exists?('.')).to be true
    end

    it "create is idempotent" do
      pt.create('test.something', new_namespace_allowed: true)
      expect(pt.create('test.something').exists?('.')).to be true
    end

    it "new_namespace_allowed is idempotent" do
      pt.create('test.something', new_namespace_allowed: true)
      expect(pt.create('test.somethingelse', new_namespace_allowed: true).exists?('.')).to be true
    end
  end


end
