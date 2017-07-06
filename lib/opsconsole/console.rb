# Tmux integration
#
class Console
  def self.attach_session(session:, window: nil, pane: nil)
    sh(%W[attach -t =#{session}:#{window}.#{pane}])
  end

  def self.sh(args)
    system('tmux', '-L', 'opsconsole', *args)
  end

  def self.kill_session(session:)
    sh(%W[kill-session -t =#{session}:])
  end

  def self.kill_pane(session:, window:, pane:)
    sh(%W[killp -t =#{session}:#{window}.#{pane}])
  end

  def self.kill_window(session:, window:)
    sh(%W[killw -t =#{session}:#{window}.])
  end

  def self.list_panes
    fmt = ['#{session_name}',
           '#{window_name}',
           '#{window_active}',
           '#{pane_index}',
           '#{pane_active}'].join(' ')
    sh(%W[lsp -a -F #{fmt}])
  end

  def self.new_session(session:, window:)
    sh(%W[new -d -s #{session} -n #{window}])
  end

  def self.new_window(session:, window:)
    sh(%W[neww -t #{session} -n #{window}])
  end

  def self.present?(target:)
    sh(%W[has -t #{target}].push(err: File::NULL))
  end

  def self.set_option(session:, option:, value:)
    sh(%W[set -t =#{session}: #{option} #{value}])
  end

  def self.set_window_option(session:, window:, option:, value:)
    sh(%W[setw -t =#{session}:#{window}. #{option} #{value}])
  end

  def self.split_window(session:, window:, pane:, direction:, size:, command: nil)
    if command.nil?
      sh(%W[splitw -t =#{session}:#{window}.#{pane} -#{direction} -p #{size}])
    else
      sh(%W[splitw -t =#{session}:#{window}.#{pane} -#{direction} -p #{size} #{command}])
    end
  end

  def self.select_pane(session:, window:, pane:)
    sh(%W[selectp -t =#{session}:#{window}.#{pane}])
  end

  def self.select_window(session:, window:)
    sh(%W[selectw -t =#{session}:#{window}.])
  end

  def self.attach(session:, window: nil, pane: nil)
    select_pane(session: session,
                window: window,
                pane: pane)
    attach_session(session: session,
                   window: window,
                   pane: pane)
  end

  def self.destroy(session:, window:)
    if session.nil?
      STDERR.puts 'can not find session'
    elsif window.nil?
      kill_session(session: session)
    else
      kill_window(session: session,
                  window: window)
    end
  end

  def self.list
    list_panes
  end

  def self.create(session:, window:, user:, hosts:, commands:, synchronize:)
    return if present?(target: "=#{session}:#{window}.1")

    if present?(target: "=#{session}:")
      create_window(session: session,
                    window: window)
    else
      create_session(session: session,
                     window: window)
    end

    create_panes(session: session,
                 window: window,
                 user: user,
                 hosts: hosts,
                 commands: commands)

    set_window_option(session: session,
                      window: window,
                      option: 'synchronize-panes',
                      value: synchronize ? 'on' : 'off')
  end

  def self.create_panes(session:, window:, user:, hosts:, commands:)
    hosts.size.downto(2) do |h|
      width = 100 / h
      split_window(session: session,
                   window: window,
                   pane: 1,
                   direction: 'h',
                   size: width)
    end

    hosts.size.downto(1) do |h|
      host = hosts[h - 1]
      ssh = "ssh -tt -o ConnectTimeout=2 #{user}@#{host}"
      commands = [ssh] if commands.empty?
      commands.size.downto(1) do |c|
        command = "#{ssh} '#{commands[c - 1]}'"
        split_window(session: session,
                     window: window,
                     pane: h,
                     direction: 'v',
                     size: 100 / c,
                     command: command)
      end
      kill_pane(session: session,
                window: window,
                pane: h)
    end

    select_pane(session: session,
                window: window,
                pane: 1)
  end

  def self.create_session(session:, window:)
    new_session(session: session,
                window: window)
    set_option(session: session,
               option: 'base-index',
               value: 1)
    set_option(session: session,
               option: 'pane-border-status',
               value: 'top')
    set_option(session: session,
               option: 'pane-border-format',
               value: '#{pane_index}')
    set_option(session: session,
               option: 'status-left-length',
               value: session.size + 4)
    set_option(session: session,
               option: 'status-right',
               value: ['#{session_name}',
                       '#{window_name}',
                       '#{pane_index}'].join(':'))
    set_window_option(session: session,
                      window: window,
                      option: 'pane-base-index',
                      value: 1)
  end

  def self.create_window(session:, window:)
    new_window(session: session,
               window: window)
    set_window_option(session: session,
                      window: window,
                      option: 'pane-base-index',
                      value: 1)
  end
end
