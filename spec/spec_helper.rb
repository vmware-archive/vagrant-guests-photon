# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.

shared_context 'machine' do
  let(:communicate) {
    double('communicate')
  }
  let(:machine) {
    v = double('machine')
    v.tap { |m| m.stub(:communicate).and_return(communicate) }
  }
  let(:guest) {
    described_class.new
  }
end
