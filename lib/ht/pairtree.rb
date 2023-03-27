require "ht/pairtree/version"

# Pairtree is ancient and throws warnings so we suppress them on require
oldverbose = $VERBOSE
$VERBOSE = nil
require "pairtree"
$VERBOSE = oldverbose

require "fileutils"

module HathiTrust
  # A simple Pairtree implementation to make it easier to work with
  # the HathiTrust pairtree structure.
  class Pairtree
    class PairtreeError < StandardError
    end

    class NamespaceDoesNotExist < PairtreeError
    end

    SDR_DATA_ROOT_DEFAULT = (ENV["SDRDATAROOT"] || "/sdr1") + "/obj"

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
    # @param [Boolean] create Whether to create the pairtree if it doesn't exist
    # @return [Pairtree] the pairtree for that object
    def pairtree_for(htid, create: false)
      pairtree_root(htid, create: create)
    end

    # Create the pairtree directory for the given htid. Allow namespace
    # creation only if told to.
    # @param htid [String] The HTID
    # @param new_namespace_allowed [Boolean] Whether or not to error if the namespace DNE
    # @raise [NamespaceDoesNotExist] if namespace DNE and new namespace not allowed
    # @return [Pairtree::Obj] the underlying pairtree object
    def create(htid, new_namespace_allowed: false)
      unless namespace_exists?(htid) || new_namespace_allowed
        raise NamespaceDoesNotExist.new("Namespace #{namespace(htid)} does not exist")
      end
      pairtree_for(htid, create: new_namespace_allowed).mk(htid)
    end

    private

    def namespace_exists?(htid)
      namespace_dir(htid).exist?
    end

    def namespace_dir(htid)
      @root + namespace(htid)
    end

    def namespace(htid)
      htid.split(".", 2).first
    end

    def pairtree_root(htid, create: false)
      ::Pairtree.at(namespace_dir(htid), prefix: pairtree_prefix(htid), create: create)
    end

    def pairtree_prefix(htid)
      namespace(htid) + "."
    end
  end
end
