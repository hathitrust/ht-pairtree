require "ht/pairtree/version"

# Pairtree is ancient and throws warnings so we suppress them on require
oldverbose = $VERBOSE
$VERBOSE = nil
require 'pairtree'
$VERBOSE = oldverbose

module HathiTrust
  # A simple Pairtree implementation to make it easier to work with
  # the HathiTrust pairtree structure.
  class Pairtree
    class PairtreeError < StandardError;
    end

    SDR_DATA_ROOT_DEFAULT = (ENV["SDRDATAROOT"] || '/sdr1') + '/obj'

    # Create a new pairtree object rooted at the given directory
    # @param [String] root The root of the pairtree (takes `ENV['SDRDATAROOT'] + 'obj'` by default)
    def initialize(root: SDR_DATA_ROOT_DEFAULT)
      @root = Pathname.new(root)
    end

    # Find the pairtree directory for the given obj.
    # @param [String] htid The HathiTrust ID for an object

    # Get a Pathname object corresponding to the directory holding data for the given HTID
    # @param [String] htid The HathiTrust ID for an object
    # @return [Pathname] Path to the given object's directory
    def path_for(htid)
      Pathname.new(pairtree_root(htid)[htid].path)
    end

    alias_method :dir, :path_for
    alias_method :[], :path_for
    alias_method :path_to, :path_for


    def pairtree(htid)
      pairtree_root[htid]
    end


    protected

    def namespace(htid)
      htid.split('.', 2).first
    end

    def pairtree_root(htid)
      ::Pairtree.at(@root + namespace(htid))
    end

  end
end
