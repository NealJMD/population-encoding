%% pop_inference: UI built up to demonstrate how the addition of firing rates 
%% of neural populations can be used to execute Bayesian inference.
function [ps] = pop_inference()

	%% gaussian_tuning: value at s of gaussian centered at k 
	function [ret] = gaussian_tuning(s, k, gain)
		ret = (normpdf(s, k, N/4) * gain);
	end

	% r is vector of firing rates, f is tuning curve
	function [p] = decode_poisson(r, f, gain)
		p = ones(1, smax);
		rifact = factorial(r);
		for s = 1:smax,
			for k=1:N,
				fsk = f(s, k, gain);
				p(s) = p(s) * (exp(-fsk) * fsk^r(k) / rifact(k))^.01;
			end
		end
	end

	% r is vector of firing rates, f is tuning curve
	function [p] = decode_exponential(r, f, gain)
		p = ones(1, smax);
		for s = 1:smax,
			for k=1:N,
				fsk = f(s, k, gain);
				d = r(k) - fsk;
				p(s) = p(s) * (exp(-fsk * d) * fsk);
			end
		end
	end

	%% decode_binomial: 
	function [p] = decode_binomial(r, f, gain)
		p = ones(1, smax);
		for s = 1:smax,
			for k=1:N,
				fsk = round(f(s, k, gain) * 2);
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

	%% normalize: make the integral of the given function = 1
	function [normalized] = normalize(in)
		normalized = in/trapz(domain,in);;
	end

	%% compute and graph: do all the heavy lifting of this thing
	function [ps] = compute_and_graph(stage)
		if (stage == 1) || (stage == 0),
			r1 = gaussian_tuning(stim1, domain, gain1);
			r1 = add_noise(r1, noise_dist, additive_noise);
			if needs_int,
				r1 = round(r1);
			end
			unnormalized_ps1 = decoder(r1, @gaussian_tuning, gain1);
			ps1 = normalize(unnormalized_ps1);
		end

		if (stage == 2) || (stage == 0),
			r2 = gaussian_tuning(stim2, domain, gain2);
			r2 = add_noise(r2, noise_dist, additive_noise);
			if needs_int,
				r2 = round(r2);
			end
			unnormalized_ps2 = decoder(r2, @gaussian_tuning, gain2);
			ps2 = normalize(unnormalized_ps2);
		end

		r3 = r1 + r2;
		unnormalized_ps3 = decoder(r3, @gaussian_tuning, (gain1+gain2)/2);
		ps3 = normalize(unnormalized_ps3);
		predicted = normalize(ps1 .* ps2);

		subplot(2, 4, 1);
		plot(domain, r1, 'o');
		subplot(2, 4, 2);
		plot(domain, ps1, '-');
		subplot(2, 4, 3);
		plot(domain, r2, 'o');
		subplot(2, 4, 4);
		plot(domain, ps2, '-');
		subplot(2, 4, 6);
		plot(domain, r3, 'o');
		subplot(2, 4, 7);
		plot(domain, ps3, '-', domain, predicted, 'x');

		drawnow;

	end

	%% callbacks on variable updates
	function [ret] = gain_changed1()
		gain1 = get_control(gain_control1);
		compute_and_graph(1);
		ret = gain1;
	end
	
	function [ret] = gain_changed2()
		gain2 = get_control(gain_control2);
		compute_and_graph(2);
		ret = gain2;
	end

	function [ret] = stim_changed1()
		stim1 = get_control(stim_control1);
		compute_and_graph(1);
		ret = stim1;
	end
	
	function [ret] = stim_changed2()
		stim2 = get_control(stim_control2);
		compute_and_graph(2);
		ret = stim2;
	end

	variability = 'poisson';
	% variability = 'binomial';
	% variability = 'exponential';

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
	stim1 = 50; % stimulus
	stim2 = 65;
	delta_stim = 5;
	gain1 = base_gain;
	gain2 = base_gain * 1.5;

	r1 = domain;
	ps1 = domain;
	r2 = domain;
	ps2 = domain;

	figure(1);
	pos = get(gcf, 'Position');
	gain_control1 = add_control('gain 1', gain1, delta_gain, delta_gain, pos(3)-350, 280, @gain_changed1);
	stim_control1 = add_control('stim 1', stim1, delta_stim, delta_stim, pos(3)-350, 260, @stim_changed1);
	gain_control2 = add_control('gain 2', gain2, delta_gain, delta_gain, pos(3)+500, 280, @gain_changed2);
	stim_control2 = add_control('stim 2', stim2, delta_stim, delta_stim, pos(3)+500, 260, @stim_changed2);
	set(gcf, 'Units', 'pixels', 'Position', [10 10 1360 700], 'Color', 'yellow');

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