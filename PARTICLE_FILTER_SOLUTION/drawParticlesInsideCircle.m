function particles = drawParticlesInsideCircle(n,x,y,radius)
or = randWithinBounds(0,360,n,1);
[xr,yr] = randWithinCircle(x,y,radius,n);

particles.x = xr;
particles.y = yr;
particles.orientation = or;

particles = table2struct(struct2table(particles));
handles = drawParticles(particles);
handles_table = array2table(handles);
particles_table = struct2table(particles);
particles = table2struct([particles_table, handles_table]);
end



