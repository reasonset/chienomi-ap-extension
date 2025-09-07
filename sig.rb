require 'openssl'
require 'base64'

def generate_signature(private_key_pem, headers, signed_headers)
  key = OpenSSL::PKey::RSA.new(private_key_pem)
  signing_string = signed_headers.map { |h| "#{h.downcase}: #{headers[h]}" }.join("\n")
  signature = key.sign(OpenSSL::Digest::SHA256.new, signing_string)
  Base64.strict_encode64(signature)
end
