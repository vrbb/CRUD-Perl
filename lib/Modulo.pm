package Modulo;
use Mojo::Base 'Mojolicious';
use Mojo::File;

use Utils::PG;
# Aquivo criado para as rotas do sistema

# declarando o módulo de conexão com o banco de dados
has _dbh => undef;


sub dbh {
	my $self = shift;

	$self->_dbh(Utils::PG->new()) unless defined $self->_dbh;

	return $self->_dbh->get_conn($self->app->config, 0);
}

# Rotas aqui
sub setup_routing {
	my $self = shift;
	 
	my $public = $self->routes;
	
}

# Adicionando o plugins
sub setup_plugins {
	my $self = shift;
	$self->app->plugin('Config',{file => "config/netmanager.conf"});
}


# método de startar o sistema 
sub startup {
	my $self = shift;

	# Mojolicious
	$self->setup_plugins;

	my $config = $self->app->config;


	my $versionFile = './VERSION';
	if(-e $versionFile and defined $versionFile){
		use Mojo::Util qw( decode );
		my $conteudo = decode('UTF-8', Mojo::File->new($versionFile)->slurp);
		chomp($conteudo);
		$self->app->hook(
			after_dispatch => sub {
				my $c = shift;
				$c->res->headers->header('revan-version' => $conteudo);
			}
		);
	}

	$self->setup_routing;
}

1;