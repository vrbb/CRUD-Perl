package Utils::PG;
# Arquivo utilizado para conexão ccom o banco de dados
use Mojo::Base -base;
use Mojo::Pg;


has _dbh => undef;
has _time => undef;

sub new {
    shift->SUPER::new(@_);
}

sub get_conn {
    my ($self, $config, $ro) = @_;

    if ((defined $self->_dbh) and (time < ($self->_time + 300))) {
        try {
            $self->_dbh->query("SELECT 1")->hash;
            say Dumper "Conectou";
            return $self->_dbh;
        }catch{
            $self->_dbh(undef);
            return $self->get_conn($config, $ro);
        }
    } elsif (defined $self->_dbh) {
        $self->_dbh->disconnect;
    }

    die('PARAMETROS_INVALIDOS: {config:required}') unless defined $config;

    my $pg = Mojo::Pg->new();
    $pg->dsn('dbi:Pg:host=' . (defined $ro and $ro eq 1 ? $config->{db_host_leitura} : $config->{db_host}) . ';dbname=' . $config->{db_name});
    $pg->username($config->{db_user});
    $pg->password($config->{db_password});
    $pg->options({AutoCommit => 1, RaiseError => 1, PrintError => 1});

    $self->_dbh($pg->db);
    $self->_time(time());

    return $self->_dbh;
}

1;