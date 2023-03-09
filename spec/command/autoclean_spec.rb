require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Autoclean do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ autoclean }).should.be.instance_of Command::Autoclean
      end
    end
  end
end

