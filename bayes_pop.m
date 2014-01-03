%% bayes_pop: encodes and decodes probability distributions into the firing patterns
%%  of a population of neurons and performs inference with them as describe in Ma 2006
function [ps] = bayes_pop()

	%% gaussian_tuning: value at s of gaussian centered at k 
	function [ret] = gaussian_tuning(s, k)
		ret = (normpdf(s, k, N/4) * gain);
	end

	% r is vector of firing rates, f is tuning curve
	function [p] = decode_poisson(r, f)
		p = ones(1, smax);
		rifact = factorial(r);
		for s = 1:smax,
			for k=1:N,
				fsk = f(s, k);
				p(s) = p(s) * (exp(-fsk) * fsk^r(k) / rifact(k))^.01;
			end
		end
	end

	% decode exponential: decode an exponential distribution from firing rates
	% r is vector of firing rates, f is tuning curve
	function [p] = decode_exponential(r, f)
		p = ones(1, smax);
		for s = 1:smax,
			for k=1:N,
				fsk = f(s, k);
				d = r(k) - fsk;
				p(s) = p(s) * (exp(-fsk * d) * fsk);
			end
		end
	end

	% decode binomial: decode a binomial distribution from firing rates
	% r is vector of firing rates, f is tuning curve
	function [p] = decode_binomial(r, f)
		p = ones(1, smax);
		for s = 1:smax,
			for k=1:N,
				fsk = round(f(s, k) * 2);
				if(fsk > r(k)),
					p(s) = p(s) * (.5^fsk * nchoosek(fsk, r(k)))^.01;
				end
			end
		end
	end

	%% binornd_wrapped: wrapper for binornd so it takes only one parameter
	function [ret] = binornd_wrapped(mu)
		ret = binornd(round(mu * 2), 0.5);
	end
	
	% add noise to a vector r by passing each element to noise_function.
	% additive controls whether noise_function(r(k)) adds to or replaces r(k)
	function [nr] = add_noise(r, noise_function, additive)
		nr = ones(1, N);
		if additive,
			for k=1:N,
				nr(k) =  r(k) + noise_function( r(k) );
			end
		else
			for k=1:N,
				nr(k) =  noise_function( r(k) );
			end
		end
	end

	%% compute and graph: do all the heavy lifting of this thing
	function [ps] = compute_and_graph(stage)
		r1 = gaussian_tuning(stim, domain);
		r1 = add_noise(r1, noise_dist, additive_noise);
		if needs_int,
			r1 = round(r1);
		end
		unnormalized_ps = decoder(r1, @gaussian_tuning);
		ps = unnormalized_ps/trapz(domain,unnormalized_ps);

		subplot(1, 2, 1);
		plot(domain, r1, 'o');
		subplot(1, 2, 2);
		plot(domain, ps, 'o');
		drawnow;

	end

	%% gain_changed: called back when gain changes
	function [ret] = gain_changed()
		gain = get_control(gain_control);
		ret = gain;
		compute_and_graph(0);
	end
	
	% variability = 'poisson';
	% variability = 'binomial';
	variability = 'exponential';

	if strcmp(variability, 'exponential')
		decoder = @decode_exponential;
		noise_dist = @exprnd;
		base_gain = 60;
		delta_gain = 5;
		needs_int = false;
		additive_noise = true;
	elseif strcmp(variability, 'binomial')
		decoder = @decode_binomial;
		noise_dist = @binornd_wrapped;
		base_gain = 5000;
		delta_gain = 400;
		needs_int = true;
		additive_noise = false;
		warning('off', 'MATLAB:nchoosek:LargeCoefficient');
	else % default to poisson
		decoder = @decode_poisson;
		noise_dist = @poissrnd;
		base_gain = 2000;
		delta_gain = 200;
		needs_int = true;
		additive_noise = true;
	end


	N = 100; % number of neurons
	domain = 1:N; 
	smax = N; % stimulus ranges 1:N
	stim = 50; % stimulus
	gain = base_gain;

	figure(1);
	pos = get(gcf, 'Position');
	gain_control = add_control('gain', gain, delta_gain, delta_gain, pos(3)-200, 20, @gain_changed);
	set(gcf, 'Units', 'pixels', 'Position', [100 20 1000 600], 'Color', 'yellow');

	% code to create gain vs. variance graphs and show decoded distributions
	% gains = 4:4:100;
	% % gains = 100:100:3000;
	% variances = gains;
	% psa = domain;
	% psb = domain;
	% psc = domain;
	% for h=1:length(gains),
	% 	gain = gains(h);
	% 	ps = compute_and_graph(0);
	% 	variance = var(domain, ps);
	% 	variances(h) = variance;
	% 	% if h==1
	% 	% 	psa = ps;
	% 	% elseif h==2
	% 	% 	psb = ps;
	% 	% else
	% 	% 	psc = ps;
	% 	% end
	% end
	% plot(domain, psa, 'o', domain, psb, 'x', domain, psc, '+');

	% var(domain, psa)
	% var(domain, psb)
	% var(domain, psc)
	% plot(gains, variances, 'o');
	compute_and_graph(0)

end