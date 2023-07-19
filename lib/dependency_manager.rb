class DependencyManager
  attr_reader :allowed_dependency_updates, :proposed_dependency_updates

  def initialize
    @allowed_dependency_updates = []
    @proposed_dependency_updates = []
  end

  def allow_dependency_update(name:, allowed_semver_bumps:)
    allowed_dependency_updates << { name:, allowed_semver_bumps: }
  end

  def propose_dependency_update(name:, previous_version:, next_version:)
    proposed_dependency_updates << { name:, previous_version:, next_version: }
  end

  def all_proposed_dependencies_on_allowlist?
    proposed_dependency_updates.each do |proposed_dependency|
      return false unless allowed_dependency_updates.find { |dep| dep[:name] == proposed_dependency[:name] }
    end

    true
  end

  def all_proposed_updates_semver_allowed?
    proposed_dependency_updates.each do |proposed_update|
      dependency_recognised = allowed_dependency_updates.find { |dep| dep[:name] == proposed_update[:name] }
      next unless dependency_recognised

      update_type = DependencyManager.update_type(proposed_update[:previous_version], proposed_update[:next_version])
      return false unless dependency_recognised[:allowed_semver_bumps].include?(update_type.to_s)
    end

    true
  end

  def self.update_type(previous_version, next_version)
    raise SemverException unless [previous_version, next_version].all? { |str| str.match?(/^[0-9]+\.[0-9]+\.[0-9]+$/) }

    prev_major, prev_minor, prev_patch = previous_version.split(".").map(&:to_i)
    next_major, next_minor, next_patch = next_version.split(".").map(&:to_i)
    return :major if (next_major - prev_major).positive?
    return :minor if (next_minor - prev_minor).positive?
    return :patch if (next_patch - prev_patch).positive?

    :unchanged
  end

  class SemverException < StandardError; end
end