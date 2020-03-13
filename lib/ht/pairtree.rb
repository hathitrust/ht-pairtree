# coding: utf-8
require "ht/pairtree/version"

# Pairtree is ancient and throws warnings so we suppress them on require
oldverbose = $VERBOSE
$VERBOSE = nil
require 'pairtree'
$VERBOSE = oldverbose

require 'fileutils'

module HathiTrust
  # A simple Pairtree implementation to make it easier to work with
  # the HathiTrust pairtree structure.
  class Pairtree

    class PairtreeError < StandardError;
    end

    class NamespaceDoesNotExist < PairtreeError
    end

    SDR_DATA_ROOT_DEFAULT = (ENV["SDRDATAROOT"] || '/sdr1') + '/obj'

    # Create a new pairtree object rooted at the given directory
    # @param [String] root The root of the über-pairtree (takes `ENV['SDRDATAROOT'] + 'obj'` by default)
    def initialize(root: SDR_DATA_ROOT_DEFAULT)
      @root = Pathname.new(root)
    end



    # Get a Pathname object corresponding to the directory holding data for the given HTID
    # @param [String] htid The HathiTrust ID for an object
    # @return [Pathname] Path to the given object's directory
    def path_for(htid)
      Pathname.new(pairtree_root(htid)[htid].path)
    end

    alias_method :dir, :path_for
    alias_method :path_to, :path_for


    # Get the underlying pairtree for the given obj.
    # @param [String] htid The HathiTrust ID for an object
    # @return [Pairtree] the pairtree for that object
    def pairtree_for(htid)
      pairtree_root(htid)
    end

    # Create a pairtree for the given htid. Allow namespace creation
    # only if told to.
    # @param htid [String] The HTID
    # @param new_namespace_allowed [Boolean] Whether or not to error if the namespace DNE
    # @raise [NamespaceDoesNotExist] if namespace DNE and new namespace not allowed
    # @return [Pairtree::Obj] the underlying pairtree object
    def create(htid, new_namespace_allowed: false)
      if !namespace_exists?(htid)
        if new_namespace_allowed
          create_namespace_dir(htid)
        else
          raise NamespaceDoesNotExist.new("Namespace #{namespace(htid)} does not exist")
        end
      end
      pairtree_for(htid).mk(htid)
    end

    def namespace_exists?(htid)
      namespace_dir(htid).exists?
    end


    def create_namespace_dir(htid)
      ndir = namespace_dir(htid)
      return self if Dir.exists?(ndir)
      Dir.mkdir(ndir)
      File.open(ndir + "pairtree_prefix", 'w:utf-8') {|f| f.print namespace(htid)}
      File.open(ndir + "pairtree_version0_1", 'w:utf-8') {|f| }
      Dir.mkdir(ndir + "pairtree_root")
      return self
    end


    def namespace_dir(htid)
      @root + namespace(htid)
    end

    def namespace(htid)
      htid.split('.', 2).first
    end

    def pairtree_root(htid)
      ::Pairtree.at(namespace_dir(htid))
    end

  end
end
