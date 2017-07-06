require 'spec_helper'

RSpec.describe Console do
  context 'tmux arguments' do
    before do
      allow(described_class)
        .to receive(:sh)
    end

    it 'attach' do
      described_class.attach(session: 'session',
                             window: 'window')

      expect(described_class)
        .to have_received(:sh)
        .with(['selectp', '-t', '=session:window.'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['attach', '-t', '=session:window.'])
        .ordered
    end

    it 'create' do
      described_class.create(session: 'session',
                             window: 'window',
                             user: 'user',
                             hosts: %w[host1 host2],
                             commands: ['ping host3',
                                        'while true; do echo $(date); sleep 1; done'],
                             synchronize: true)

      expect(described_class)
        .to have_received(:sh)
        .with(['has', '-t', '=session:window.1', { err: '/dev/null' }])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['has', '-t', '=session:', { err: '/dev/null' }])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['new', '-d', '-s', 'session', '-n', 'window'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['set', '-t', '=session:', 'base-index', '1'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['set', '-t', '=session:', 'pane-border-status', 'top'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['set', '-t', '=session:', 'pane-border-format', '#{pane_index}'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['set', '-t', '=session:', 'status-left-length', '11'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['set', '-t', '=session:', 'status-right', '#{session_name}:#{window_name}:#{pane_index}'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['setw', '-t', '=session:window.', 'pane-base-index', '1'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['splitw', '-t', '=session:window.1', '-h', '-p', '50'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['splitw', '-t', '=session:window.2', '-v', '-p', '50',
               'ssh -tt -o ConnectTimeout=2 user@host2 \'while true; do echo $(date); sleep 1; done\''])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['splitw', '-t', '=session:window.2', '-v', '-p', '100',
               'ssh -tt -o ConnectTimeout=2 user@host2 \'ping host3\''])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['killp', '-t', '=session:window.2']).ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['splitw', '-t', '=session:window.1', '-v', '-p', '50',
               'ssh -tt -o ConnectTimeout=2 user@host1 \'while true; do echo $(date); sleep 1; done\''])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['splitw', '-t', '=session:window.1', '-v', '-p', '100',
               'ssh -tt -o ConnectTimeout=2 user@host1 \'ping host3\''])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['killp', '-t', '=session:window.1'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['selectp', '-t', '=session:window.1'])
        .ordered
      expect(described_class)
        .to have_received(:sh)
        .with(['setw', '-t', '=session:window.', 'synchronize-panes', 'on'])
        .ordered
    end

    it 'destroy' do
      described_class.destroy(session: 'session',
                              window: 'window')

      expect(described_class)
        .to have_received(:sh)
        .with(['killw', '-t', '=session:window.'])
        .ordered
    end

    it 'list' do
      described_class.list

      expect(described_class)
        .to have_received(:sh)
        .with(['lsp', '-a', '-F', '#{session_name} #{window_name} #{window_active} #{pane_index} #{pane_active}'])
        .ordered
    end
  end
end
