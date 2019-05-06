require 'pairtree'
require 'fileutils'
require 'tmpdir'


RSpec.describe HathiTrust::Pairtree do
  TMPDIR = Pathname.new(Dir.mktmpdir)
  puts TMPDIR

  idmap = {
    'uc1.c3292592'             => 'sdr1/obj/uc1/pairtree_root/c3/29/25/92/c3292592',
    'loc.ark:/13960/t9w09k00s' => 'sdr1/obj/loc/pairtree_root/ar/k+/=1/39/60/=t/9w/09/k0/0s/ark+=13960=t9w09k00s',
    'ia.ark:/13960/t9w10cs7x'  => 'sdr1/obj/ia/pairtree_root/ar/k+/=1/39/60/=t/9w/10/cs/7x/ark+=13960=t9w10cs7x'
  }


  before(:context) do
    idmap.values.each do |subdir|
      dir = TMPDIR + subdir
      puts "Trying to make #{dir}"
      FileUtils.mkdir_p(dir)
      root   = TMPDIR + Pathname.new(subdir.split('/')[0..2].join('/'))
      prefix = subdir.split('/')[2]
      File.open(root + 'pairtree_prefix', 'w:utf-8') do |pp|
        pp.print(prefix + '.')
      end
      File.open(root + 'pairtree_version0_1', 'w:utf-8') {}
    end
  end

  after(:context) do
    FileUtils.rm_f(TMPDIR)
  end


  it "has a version number" do
    expect(HathiTrust::Pairtree::VERSION).not_to be nil
  end


  describe "translates names into directories" do
    pt = HathiTrust::Pairtree.new(root: TMPDIR + 'sdr1/obj')

    idmap.each_pair do |id, dir|
      it id do
        expect(pt.path_for(id).to_s).to eq((TMPDIR + dir).to_s)
      end
    end
  end

  it "Can create new object directories" do
    pt = HathiTrust::Pairtree.new(root: TMPDIR + 'sdr1/obj')
    expect {pt.create('bill.dueber', create_new_namespace: false)}.to raise_error(Pairtree::PathError)
    expect(pt.create('bill.dueber', create_new_namespace: true).exists?('.')).to be true
  end


end
