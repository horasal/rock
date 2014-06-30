/* The Computer Language Benchmarks Game
 * Written in OOC language
 * Hongjie Zhai
 */
import math

solarMass : static Double = 4*PI*PI
daysPerYear : static Double = 365.24

Body: class{
	x,y,z,vx,vy,vz,mass: Double

	init: func(=x,=y,=z,=vx,=vy,=vz,=mass){
	}

	offsetMomentum: func(px,py,pz: Double){
		vx = -px /solarMass;
		vy = -py /solarMass;
		vz = -pz /solarMass;
	}
}

System: class{
	sys: Body[];

	init: func(=sys){
		px: Double = 0
		py: Double = 0
		pz: Double = 0
		for(i in 0..sys length){
			px += sys[i] vx * sys[i] mass
			py += sys[i] vy * sys[i] mass
			pz += sys[i] vz * sys[i] mass
		}
		sys[0] offsetMomentum(px,py,pz)
	}

	energy: func() -> Double{
		e:Double = 0
		for(i in 0..sys length){
			d := sys[i]
			e += 0.5 * d mass * ( d vx * d vx + d vy * d vy + d vz * d vz)
			for(j in i+1..sys length){
				dx: Double = d x - sys[j] x
				dy: Double = d y - sys[j] y
				dz: Double = d z - sys[j] z
				distance: Double = sqrt(dx*dx + dy*dy + dz*dz)
				e -= (d mass * sys[j] mass) / distance
			}
		}
		return e
	}

	advance: func(dt: Double) {
		for(i in 0..sys length){
			d := sys[i]
			for(j in i+1..sys length){
				dx: Double = d x - sys[j] x
				dy: Double = d y - sys[j] y
				dz: Double = d z - sys[j] z
				distance := sqrt(dx*dx + dy*dy + dz*dz)
				mag := dt/(distance * distance * distance)

				d vx -= dx * sys[j] mass * mag
				d vy -= dy * sys[j] mass * mag
				d vz -= dz * sys[j] mass * mag

				sys[j] vx += dx * d mass * mag
				sys[j] vy += dy * d mass * mag
				sys[j] vz += dz * d mass * mag
			}
		}
		for(i in 0..sys length){
			d := sys[i]
			d x += dt * d vx
			d y += dt * d vy
			d z += dt * d vz
		}
	}
}

main: func(argc: Int, argv: CString*) -> Int{
	n: Int
	if(argc > 1) n = argv[1] toString() toInt()
	else return 1

	sys := System new([
		Body new(0,0,0,0,0,0,solarMass),

        Body new(4.84143144246472090e+00,
       -1.16032004402742839e+00,
       -1.03622044471123109e-01,
       1.66007664274403694e-03 * daysPerYear,
       7.69901118419740425e-03 * daysPerYear,
       -6.90460016972063023e-05 * daysPerYear,
       9.54791938424326609e-04 * solarMass),

       Body new(8.34336671824457987e+00,
       4.12479856412430479e+00,
       -4.03523417114321381e-01,
       -2.76742510726862411e-03 * daysPerYear,
       4.99852801234917238e-03 * daysPerYear,
       2.30417297573763929e-05 * daysPerYear,
       2.85885980666130812e-04 * solarMass),

       Body new(1.28943695621391310e+01,
       -1.51111514016986312e+01,
       -2.23307578892655734e-01,
       2.96460137564761618e-03 * daysPerYear,
       2.37847173959480950e-03 * daysPerYear,
       -2.96589568540237556e-05 * daysPerYear,
       4.36624404335156298e-05 * solarMass),

       Body new(1.53796971148509165e+01,
       -2.59193146099879641e+01,
       1.79258772950371181e-01,
       2.68067772490389322e-03 * daysPerYear,
       1.62824170038242295e-03 * daysPerYear,
       -9.51592254519715870e-05 * daysPerYear,
       5.15138902046611451e-05 * solarMass)
	])

	"%.9f" printfln(sys energy())
	for(i in 0..n) sys advance(0.01)
	"%.9f" printfln(sys energy())

	return 0
}
