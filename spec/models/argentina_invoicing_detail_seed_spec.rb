require 'rails_helper'
require 'helpers/shared_examples_for_models'

RSpec.describe ArgentinaInvoicingDetailSeed, type: :model do
  %i(tax_id full_name address country).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    vat_status_code: :monotributo,
    tax_id: ' 20955754290',
    tax_id_kind_code: :cuit,
    receipt_kind_code: :a,
    full_name: 'Luis Miguel   ',
    address: '   Jujuy 3421',
    country: 'AR '
  }
end