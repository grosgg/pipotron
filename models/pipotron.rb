class Pipotron
  def self.indexes_to_hash indexes
    indexes.map{ |index| alphanumbers[index] }.join('')
  end

  def self.hash_to_indexes hash
    hash.chars.map { |char| alphanumbers.index(char) }
  end

  private

  def self.alphanumbers
    ('0'..'9').to_a + ('a'..'z').to_a
  end
end