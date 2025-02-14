# lib/soft_deletable.rb

=begin
  SoftDeletable is intended to be included into
  models that wrap ActuveRecird models which
  have a "deleted_at" timestamp column.  This
  module includes common methods for use with instances
  and classes.

  Example Usage:
    class ClinicianAddress < ActiveRecord::Base
      include SoftDeletable
    end
=end

module SoftDeletable

  def soft_deletable?
    respond_to? :deleted_at
  end


  def soft_delete!
    raise "NotSoftDeletable" unless soft_deletable?
    update_column(:deleted_at, Time.current)
  end
  alias_method :soft_delete, :soft_delete!


  def soft_deleted?
    raise "NotSoftDeletable" unless soft_deletable?
    !deleted_at.blank?
  end
end # module SoftDeletable


__END__

Removed these two methods because the codebase has some AR models
that define their own active? method based upon something different
from the deleted_at column.

It would not have been a technical conflict because the locally defined
methods would over-ride the included methods from the library module
however, some developers thought that it might be confusing to 
future maintenance programmers.

  def active?
    raise "NotSoftDeletable" unless soft_deletable?
    deleted_at.blank?
  end


  def inactive?
    raise "NotSoftDeletable" unless soft_deletable?
    !deleted_at.blank?
  end
